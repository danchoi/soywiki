require 'string_ext'

module Soywiki
  VERSION = '0.7.6'
  WIKI_WORD = /\b([a-z][\w_]+\.)?[A-Z][a-z]+[A-Z]\w*\b/
  HYPERLINK = %r|\bhttps?://[^ >)\n\]]+|

  def self.run
    if %W( -v --version -h --help).include?(ARGV.first)
      puts "soywiki #{Soywiki::VERSION}"
      puts "by Daniel Choi dhchoi@gmail.com"
      puts
      puts <<END
---
Usage: soywiki 

Run the command in a directory you've made to contain soywiki files.

Soywiki will open the most recently modified wiki file or create a file
called main/HomePage. 
---
END
      exit
    elsif ARGV.first == '--html'
      if ARGV[1] == '--markdown'
        puts "Exporting html using markdown"
        self.html_export(true)
      else
        puts "Exporting html"
        self.html_export
      end
      exit
    elsif ARGV.first == '--install-plugin'
      require 'erb'
      plugin_template = File.read(File.join(File.dirname(__FILE__), 'plugin.erb'))
      vimscript_file = File.join(File.dirname(__FILE__), 'soywiki.vim')
      plugin_body = ERB.new(plugin_template).result(binding)
      `mkdir -p #{ENV['HOME']}/.vim/plugin`
      File.open("#{ENV['HOME']}/.vim/plugin/soywiki_starter.vim", "w") {|f| f.write plugin_body}
    else
      vim = ENV['SOYWIKI_VIM'] || 'vim'
      vimscript = File.expand_path("../soywiki.vim", __FILE__)
      vim_command = "#{vim} -S #{vimscript}"
      exec vim_command
    end
  end

  def self.html_export(markdown=false)
    require 'soywiki/html'
    Html.export(markdown)
  end
end

if __FILE__ == $0
  Soywiki.run
end
