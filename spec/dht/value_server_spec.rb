require 'spec_helper'
require 'dht/value_server'
require 'dht/ping_server'

include DHT

describe ValueServer do
  include Rack::Test::Methods
  attr_reader :app, :node
  def node()  @node ||= Node.new('http://some_node')  end
  def app()   @app ||= PingServer.new( ValueServer.new(nil, node), node )  end

  before do
    Timecop.freeze
    app
    @value = 'some data'
    @key = Key.for_content 'some key'

    @self_peer = Peer.new 'http://other_node'
    @self_peer.touch
    header 'X-PEER-URL', @self_peer.url.to_s
    header 'ACCEPT', 'application/json'
    @url = app.app.opts[:prefix]
  end

  it 'returns a list of all values (index)' do
    @node.store( @key, @value )
    get @url
    last_response.should be_ok
    last_response.body.strip.should == JSON.generate([{@key => @value}])
  end

  it 'stores a value (STORE)' do
    post "#{@url}/#{@key}", JSON.generate([@value]), 'CONTENT_TYPE' => 'application/json'
    last_response.should be_ok
    JSON.parse(last_response.body)['stored'].should == 1
    @node.peers.all.size.should == 1
    @node.values.entries.size.should == 1
  end

  it 'renders a list of values (FIND_VALUE)' do
    @node.store( @key, @value )
    get "#{@url}/#{@key}"
    last_response.should be_ok
    last_response.body.strip.should == JSON.generate({values: [@value], peers: [@self_peer.to_hash]})
  end
end
