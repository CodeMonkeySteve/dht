require 'spec_helper'
require 'server/ui_server'

include DHT

describe UIServer do
  include Rack::Test::Methods
  attr_reader :app, :node
  def app()  @app ||= UIServer.new  end

  before do
    Timecop.freeze
    app
  end

  it 'renders the index page' do
    get '/'
    last_response.should be_ok
  end

  it 'renders the application stylesheet' do
    get '/application.css'
    last_response.should be_ok
  end
end
