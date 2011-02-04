require 'couchrest'
require 'zenwiki/couch'
require 'zenwiki/version'
require 'zenwiki/options'

class Zenwiki
  DB = CouchRest.database!("http://127.0.0.1:5984/zenwiki")

  class << self
    def start
      puts "Starting zenwiki #{Zenwiki::VERSION}"
      vim = ENV['ZENWIKI_VIM'] || 'vim'
      opts = Zenwiki::Options.new(ARGV)
      config = opts.config
    end
  end
end

if __FILE__ == $0
  Zenwiki.start
end
