$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')
require 'couchrest'
require 'yaml'
require 'json'
require 'rake'
require 'rake/testtask'
require 'bundler'
require 'soywiki'

Bundler::GemHelper.install_tasks

desc "build and push website"
task :web do
  version = Soywiki::VERSION
  Dir.chdir("website") do
    puts "updating website"
    puts `./run.sh #{Soywiki::VERSION}`
  end
end

desc "build website locally"
task :weblocal => :build_webpage do
  Dir.chdir("website") do
    `open soywiki.html`
  end
end

desc "build webpage"
task :build_webpage do
  $LOAD_PATH.unshift 'website'
  require 'gen'
  Dir.chdir("website") do
    html = Webpage.generate(Soywiki::VERSION)
    File.open('soywiki.html', 'w') {|f| f.puts html}
  end
end

desc "Run tests"
task :test do 
  $:.unshift File.expand_path("test")
  MiniTest::Unit.autorun
end

task :default => :test


