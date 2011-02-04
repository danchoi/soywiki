require 'couchrest'
require 'zenwiki/couch'
require 'zenwiki/version'
require 'zenwiki/options'
require 'zenwiki/server'

class Zenwiki
  DBNAME = 'zenwiki'
  DB = CouchRest.database!("http://127.0.0.1:5984/#{DBNAME}")
  SANDBOX = "zenwiki-sandbox"

  class << self
    def start
      `mkdir -p zenwiki-sandbox`
      STDERR.puts "Starting zenwiki #{Zenwiki::VERSION}"
      vim = ENV['ZENWIKI_VIM'] || 'vim'
      opts = Zenwiki::Options.new(ARGV)
      config = opts.config
      drb_uri = Zenwiki::Server.start
      server = DRbObject.new_with_uri drb_uri

      buffer_file = "zenwiki-buffer"
      vimscript = File.expand_path("../zenwiki.vim", __FILE__)
      vim_command = "DRB_URI='#{drb_uri}' ZEN_WIKI_SANDBOX='#{SANDBOX}' #{vim} -S #{vimscript} #{buffer_file}"
      STDERR.puts "Starting vim with `#{vim_command}`"
      File.open(buffer_file, "w") do |file|
        # TODO load ZenWiki home page
        file.puts "ZenWiki"
      end
      puts system(vim_command)
      if vim == 'mvim'
        DRb.thread.join
      end
      File.delete(buffer_file)

    end
  end
end

if __FILE__ == $0
  Zenwiki.start
end
