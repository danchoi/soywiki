require 'drb'
require 'logger'

class Zenwiki
  class Server
    include Couch

    def initialize(config={'logfile' => 'zenwiki.log'})
      @logger = Logger.new(config['logfile'] || STDERR)
      @logger.level = Logger::DEBUG 
    end

    def save_page(page)
      title, body = *(page.strip.split(/\n/,2))
      log "Saving page '#{title}'"
      doc = {'_id' => title, 'body' => (body || '').strip, 'type' => 'page', 'updated_at' => Time.now.utc}
      create_or_update doc
    end

    def list_pages
      log "Listing pages"
      res = view('zenwiki/recently_touched_pages', :descending => true)['rows'].map {|row|
        updated_at, title = *row["key"]
        title
      }.join("\n")
    rescue
      log $!
    end

    def load_page(title)
      doc = find_or_create({'_id' => title})
      page = textify(doc)
      file = File.join(SANDBOX, title)
      unless File.size?(file)
        log "Writing file: #{file}"
        File.open(file, 'w') {|f| f.puts page}
      end
    end

    def textify(doc)
      [ doc['_id'] , "", doc['body'] ].join("\n")
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
