
class String
  def is_namespaced?
    self.split(/\.|\//).size == 2
  end

  alias :namespaced? :is_namespaced?

  # TODO change this to a Windows compatible approach
  def to_file_path
    self.gsub(".", "/")
  end

  def to_page_title
    self.gsub("/", ".")
  end

  def short_page_title
    self.to_page_title.split('.')[1]
  end

  def namespace
    return nil unless self.namespaced?
    self.to_page_title.split('.')[0]
  end
end


module Soywiki
  VERSION = '0.0.2'
  WIKI_WORD = /\b([a-z][\w_]+\.)?[A-Z][a-z]+[A-Z]\w*\b|\.[A-Z][a-z]+[A-Z]\w*\b/

  def self.run
    if %W( -v --version -h --help).include?(ARGV.first)
      puts "soywiki #{Soywiki::VERSION}"
      puts "by Daniel Choi dhchoi@gmail.com"
      puts
      puts <<END
---
Usage: soywiki [wiki file]

Run the command in a directory you've made to contain soywiki files.

Specifying a wiki file is optional. If you don't specify a file, soywiki will
open the most recently modified wiki file. 
---
END
      exit
    end

    vim = ENV['SOYWIKI_VIM'] || 'vim'
    vimscript = File.expand_path("../soywiki.vim", __FILE__)
    vim_command = "#{vim} -S #{vimscript} #{ARGV.first}"
    exec vim_command
  end
end

