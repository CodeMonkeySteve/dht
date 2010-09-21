require 'spec_helper'
require 'dht/value_server'

include DHT

describe ValueServer do
  include Rack::Test::Methods
  attr_reader :app, :node
  def node()  @node ||= Node.new('http://some_node')  end
  def app()   @app ||= ValueServer.new(nil, node)  end

  before do
    Timecop.freeze
    @node = @app = nil
    app
    @value = 'some data'
    @key = Key.for_content 'some key'

    @self_peer = Peer.new('http://other_node').touch
    header 'X-PEER-URL', @self_peer.url.to_s
    header 'ACCEPT', 'application/json'
  end

  it 'returns a list of all values (index)' do
    @node.store( @key, @value )
    get app.class::Path
    last_response.should be_ok
    last_response.body.strip.should == JSON.generate({ values: [{key: @key.to_s, value: @value}] })
  end

  it 'stores a value (STORE)' do
    post "#{app.class::Path}/#{@key}", JSON.generate([@value]), 'CONTENT_TYPE' => 'application/json'
    last_response.should be_ok
    JSON.parse(last_response.body)['stored'].should == 1
    @node.peers.to_a.size.should == 1
    @node.values.entries.size.should == 1
  end

  it 'renders a list of values (FIND_VALUE)' do
    @node.store( @key, @value )
    get "#{app.class::Path}/#{@key}"
    last_response.should be_ok
    last_response.body.strip.should == JSON.generate({key: @key.to_s, values: [@value], peers: [@self_peer.to_hash]})
  end
end
