require 'dht/node'

module DHT

class UIServer < Sinatra::Base
  set :app_file, __FILE__
  set :show_exceptions, false
  set :dump_errors, true

  get '/' do
    haml :index
  end

  get '/application.css' do
    content_type 'text/css', :charset => 'utf-8'
    sass :application
  end
end

end