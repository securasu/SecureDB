require 'base64'
require 'json'
require 'openssl'
require 'securedb/crypto'
require 'securedb/errors'

module SecureDB
  class Database
    def initialize key
      @dataset = Hash.new ''
      @base_key = key
      load_static if File.exist? '/etc/SecureDB/SecureDB.db'
    end
    
    def set key, value
      @dataset[key] = value
    end
    
    def get key
      @dataset[key]
    end

    def delete key
      return false unless @dataset.include? key
      @dataset.delete key
      true
    end

    def save_static
      hsh = Hash.new
      hsh.merge! @dataset
      encrypt_all hsh
      str = hsh.to_json
      str = Crypto.encrypt str, @base_key
      asc = Crypto.sign(OpenSSL::Digest::SHA1.digest str)
      File.write '/etc/SecureDB/SecureDB.db', str
      File.write '/etc/SecureDB/SecureDB.db.asc', asc
    end

    def load_static
      str = File.read '/etc/SecureDB/SecureDB.db'
      asc = File.read '/etc/SecureDB/SecureDB.db.asc'
      raise DBSignError unless Crypto.verify OpenSSL::Digest::SHA1.digest(str), asc
      str = Crypto.decrypt str, @base_key
      hsh = JSON.load str
      decrypt_all hsh
      @dataset = hsh
    end

    def encrypt_all hash
      hash.each do |k, v|
        round_key = OpenSSL::Digest::SHA1.digest k + @base_key
        tmp = Crypto::encrypt v.to_json, round_key
        hash[k] = Base64::strict_encode64 tmp
      end
    end

    def decrypt_all hash
      hash.each do |k, v|
        round_key = OpenSSL::Digest::SHA1.digest k + @base_key
        tmp = Base64::strict_decode64 v
        hash[k] = JSON.load(Crypto::decrypt tmp, round_key)
      end
    end
  private
    @dataset
    @base_key
  end
end
