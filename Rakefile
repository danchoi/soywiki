$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')
require 'couchrest'
require 'yaml'
require 'json'
require 'rake'
require 'rake/testtask'
require 'bundler'
require 'soywiki'

Bundler::GemHelper.install_tasks


desc "release and build and push new website"
task :push => [:release, :web]

desc "Bumps version number up one and git commits"
task :bump do
  basefile = "lib/soywiki.rb"
  file = File.read(basefile)
  oldver = file[/VERSION = '(\d.\d.\d)'/, 1]
  newver_i = oldver.gsub(".", '').to_i + 1
  newver = ("%.3d" % newver_i).split(//).join('.')
  puts oldver
  puts newver
  puts "Bumping version: #{oldver} => #{newver}"
  newfile = file.gsub("VERSION = '#{oldver}'", "VERSION = '#{newver}'") 
  File.open(basefile, 'w') {|f| f.write newfile}
  `git commit -am 'Bump'`
end

desc "build and push website"
task :web => :build_webpage do
  puts "Building and pushing website"
  `scp website/soywiki.html zoe2@instantwatcher.com:~/danielchoi.com/public/software/`
  `open http://danielchoi.com/software/soywiki.html`
end

desc "build website locally"
task :build_web_locally => :build_webpage do
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


