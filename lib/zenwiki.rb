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
      vimscript = File.expand_path("../zenwiki.vim", __FILE__)
      vim_command = "DRB_URI='#{drb_uri}' ZEN_WIKI_SANDBOX='#{SANDBOX}' #{vim} -S #{vimscript}"
      STDERR.puts "Starting vim with `#{vim_command}`"
      puts system(vim_command)
      if vim == 'mvim'
        DRb.thread.join
      end
      # cleanup
      File.delete(buffer_file)
      `rm -rf #{SANDBOX}`
    end
  end
end

if __FILE__ == $0
  Zenwiki.start
end
