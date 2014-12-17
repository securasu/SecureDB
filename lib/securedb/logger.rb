require 'date'

module SecureDB
  class Logger
    @dst
    attr_accessor :dst

    def initialize dst = STDOUT
      @dst = dst
    end

    def log msg
      @dst << Time.now.to_s << ' ' << msg << "\n"
    end
  end
end
