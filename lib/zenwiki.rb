require 'couchrest'
require 'zenwiki/couch'
require 'zenwiki/version'

class Zenwiki
  DB = CouchRest.database!("http://127.0.0.1:5984/zenwiki")

  class << self
    def start
      puts "starting zenwiki #{Zenwiki::VERSION}"
      vim = ENV['ZENWIKI_VIM'] || 'vim'
      opts = Zenwiki::Options.new(ARGV)
      config = opts.config

    end
  end

end

