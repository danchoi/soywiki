require 'drb'

class Zenwiki
  class Server

    def initialize
    end

    def self.start
      DRb.start_service(nil, self.new)
      DRb.uri
    end
  end
end
