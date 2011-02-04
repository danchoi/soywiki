require 'drb'
require 'logger'

class Zenwiki
  class Server

    def initialize(config={'logfile' => 'zenwiki.log'})
      @logger = Logger.new(config['logfile'] || STDERR)
      @logger.level = Logger::DEBUG 
    end

    def save_page(page)
      log "Saving page"
      log page
    end

    def log(text)
      @logger.debug text
    end

    def self.start
      DRb.start_service(nil, self.new)
      DRb.uri
    end
  end
end
