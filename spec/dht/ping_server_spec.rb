require 'spec_helper'
require 'dht/ping_server'

include DHT

describe PingServer do
  include Rack::Test::Methods
  attr_reader :app, :node
  def app()  @app ||= PingServer.new(nil, @node ||= Node.new('http://some_node'))  end

  before do
    Timecop.freeze
    app
    @self_peer = Peer.new 'http://other_node'
    @self_peer.touch
    header 'X-PEER-URL', @self_peer.url.to_s
  end

  it 'accepts a ping (PING)' do
    head '/'
    last_response.should be_ok
    @node.peers.all.size.should == 1
  end
end
