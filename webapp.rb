require 'haml'
require 'sinatra'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')
require 'zenwiki'

Z = Zenwiki::Server.new 'logfile' => STDERR

get '/' do
  Z.list_pages
  haml :index
end

get '/:page' do
  Z.load_page(params[:page])
end

