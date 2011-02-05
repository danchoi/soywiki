require 'couchrest'
require 'zenwiki/couch'
require 'zenwiki/version'
require 'zenwiki/options'
require 'zenwiki/server'

class Zenwiki
  DBNAME = 'zenwiki'
  DB = CouchRest.database!("http://127.0.0.1:5984/#{DBNAME}")
  SANDBOX = "zenwiki-sandbox"

  def self.start
    `mkdir -p zenwiki-sandbox`
    STDERR.puts "Starting zenwiki #{Zenwiki::VERSION}"
    vim = ENV['ZENWIKI_VIM'] || 'vim'
    vimscript = File.expand_path("../zenwiki.vim", __FILE__)
    vim_command = "ZEN_WIKI_SANDBOX='#{SANDBOX}' #{vim} -S #{vimscript}"
    STDERR.puts "Starting vim with `#{vim_command}`"
    exec(vim_command)
  end

end

if __FILE__ == $0
  Zenwiki.start
end
