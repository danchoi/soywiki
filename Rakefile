$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')
require 'couchrest'
require 'yaml'
require 'json'
require 'rake'
require 'rake/testtask'
require 'bundler'
# require 'soywiki'

Bundler::GemHelper.install_tasks

desc "Start Sinatra webapp"
task :sinatra do
# TODO
end

desc "Run tests"
task :test do 
  $:.unshift File.expand_path("test")
  MiniTest::Unit.autorun
end

task :default => :test


