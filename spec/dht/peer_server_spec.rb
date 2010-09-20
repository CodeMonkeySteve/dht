require 'spec_helper'
require 'dht/peer_server'

include DHT

describe PeerServer do
  include Rack::Test::Methods
  attr_reader :app, :node
  def node()  @node ||= Node.new('http://some_node')  end
  def app()   @app ||= PeerServer.new(nil, node)  end

  before do
    Timecop.freeze
    @node = @app = nil
    app
    @key = Key.for_content 'some key'
    @self_peer = Peer.new('http://other_node').touch
    header 'X-PEER-URL', @self_peer.url.to_s
    header 'ACCEPT', 'application/json'
  end

  it 'returns a list of all peers' do
    get app.opts[:prefix]
    last_response.should be_ok
    last_response.body.strip.should == JSON.generate([@self_peer.to_hash])
  end

  it 'renders a list of peers (FIND_NODE)' do
    get "#{app.opts[:prefix]}/#{@key}"
    last_response.should be_ok
    last_response.body.strip.should == JSON.generate([@self_peer.to_hash])
  end
end
