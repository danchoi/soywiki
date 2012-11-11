require 'string_ext'
module Template_Substitution; end
module Soywiki
  VERSION = '0.9.1'
  WIKI_WORD = /\b([a-z0-9][\w_]+\.)?[A-Z][a-z]+[A-Z0-9]\w*\b/
  HYPERLINK = %r|\bhttps?://[^ >)\n\]]+|

  def self.run
    require 'getoptlong'

    opts = GetoptLong.new(
      [ '--help',    '-h',     GetoptLong::NO_ARGUMENT],
      [ '--version', '-v',     GetoptLong::NO_ARGUMENT],
      [ '--html',              GetoptLong::NO_ARGUMENT],
      [ '--markdown',          GetoptLong::NO_ARGUMENT],
      [ '--page',              GetoptLong::REQUIRED_ARGUMENT],
      [ '--index',             GetoptLong::REQUIRED_ARGUMENT],
    )

    usage =->  do
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
    end
    install_plugin = false
    html           = false
    md             = false
    index = page = nil
    opts.each do |opt, arg|
      case opt
        when '--help' then usage[]
        when '--version' then usage[]
        when '--html' then html = true
        when '--markdown' then md = true
        when '--install-plugin' then install_plugin = true
        when '--page' then page = arg
        when '--index' then index = arg
      end
    end
    self.set_substitute %{INDEX_PAGE_TEMPLATE_SUB}.to_sym, index if index
    self.set_substitute %{PAGE_TEMPLATE_SUB}.to_sym, page if page
    self.html_export md if html
    if install_plugin
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
    end unless html
  end

  def self.html_export(markdown=false)
    require 'soywiki/html'
    Html.export(markdown)
  end

  def self.set_substitute const, substitute_path
    substitute = File.read(substitute_path)
    Template_Substitution.const_set const.to_sym, substitute
  end
end

if __FILE__ == $0
  Soywiki.run
end
