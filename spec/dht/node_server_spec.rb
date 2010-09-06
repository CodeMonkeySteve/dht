require 'spec_helper'
require 'dht/node_server'
require 'rack/test'

include DHT

describe NodeServer do
  include Rack::Test::Methods
  def app()  @app ||= NodeServer.new  end

  before do
    app
    @node = app.instance_variable_get(:@app).node
    @host = Host.new('http://some_host').touch
    @key = Key.for_content 'some data'

    @self_peer = Peer.new 'http://other_node'
    @self_peer.touch
    header 'X-PEER-URL', @self_peer.url
  end

  it 'accepts a ping (PING)' do
    head '/'
    last_response.should be_ok
    @node.peers.all.size.should == 1
  end

  it 'accepts an uploaded block (STORE))' do
    post "/block/#{@key}", JSON.generate([@host]), 'CONTENT_TYPE' => 'application/json'
    last_response.should be_ok
    JSON.parse(last_response.body)['stored'].should == 1
    @node.peers.all.size.should == 1
    @node.hosts.hosts.size.should == 1
  end

  it 'renders a list of peers (FIND_NODE)' do
    get "/peer/#{@key}"
    @node.peers.all.size.should == 1
    last_response.should be_ok
    last_response.body.strip.should == JSON.generate({peers: [@self_peer.to_hash]})
  end

  it 'renders a list of blocks (FIND_VALUE)' do
    @node.store( @key, @host )
    get "/block/#{@key}"
    last_response.should be_ok
    last_response.body.strip.should == JSON.generate({hosts: [@host], peers: [@self_peer.to_hash]})
  end
end
