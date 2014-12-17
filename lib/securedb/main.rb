require 'io/console'
require 'socket'
require 'securedb/database'
require 'securedb/logger'
require 'securedb/errors'

module SecureDB
  Main = Class.new

  def Main::init master_key, log_dst = STDOUT
    @@db = Database.new(OpenSSL::Digest::SHA1.digest 'SecureDB' + master_key)
    @@logger = Logger.new log_dst
  end

  def Main::recv client
    client.readline
  end
  
  def Main::handle_request client, sockaddr, request
    response = Hash.new
    key = request['key']
    response['method'] = request['method']
    case request['method']
      when 'get'
        response[key] = @@db.get request['key']
      when 'set'
        @@db.set key, request['value']
        response[key] = 'ok'
      when 'delete'
        rs = @@db.delete key
        response[key] = (rs == true ? 'ok' : 'nonexisted')
      when 'save'
        @@db.save_static
        response['method'] = 'ok'
      else
        response['method'] = 'error'
    end
    port, addr = Socket.unpack_sockaddr_in sockaddr
    @@logger.log addr + ':' + port.to_s + ' ' + request['method']
    reply = response.to_json
    client << reply
  end
  
  def Main::run
    Dir.mkdir '/etc/SecureDB' unless Dir.exist? '/etc/SecureDB'
    STDERR.print 'Please input the Master Key: '
    master_key = STDIN.noecho &:gets
    master_key.chomp!
    STDERR.puts "\nBootstraping"
    begin
      Crypto.init
      init master_key
    rescue JSON::JSONError, OpenSSL::Cipher::CipherError, DBSignError
      STDERR.puts 'Bootstrap failed'
      exit -1
    end
    serve = Socket.new :INET, :STREAM
    sockaddr = Socket.pack_sockaddr_in 3399, ''
    serve.bind sockaddr
    serve.listen 10
    STDERR.puts 'Listening'
    begin
      loop do
        client, client_sockaddr = serve.accept
        json = recv client
        request = JSON.load json
        handle_request client, client_sockaddr, request
        client.close
      end
    rescue Interrupt
      STDERR.puts 'Exiting with data saving...'
      @@db.save_static
    ensure
      serve.close
    end
  end
end
