require 'spec_helper'
require 'dht/host_server'

include DHT

describe HostServer do
  include Rack::Test::Methods
  attr_reader :app, :node
  def node()  @node ||= Node.new('http://some_node')  end
  def app()   @app ||= HostServer.new(nil, node)  end

  before do
    Timecop.freeze
    @node = @app = nil
    app
    @url = 'http://nowhere.invalid'
    @key = Key.for_content 'some key'
    @host = @node.store @key, @url

    @self_peer = Peer.new('http://other_node').touch
    header 'X-PEER-URL', @self_peer.url.to_s
    header 'ACCEPT', 'application/json'
  end

  it 'returns a list of all hosts (index)' do
    get app.class::Path
    last_response.should be_ok
    last_response.body.strip.should == JSON.generate({ hosts: [@host.to_hash(:key => @key.to_s)] })
  end

  it 'stores a host (STORE)' do
    post "#{app.class::Path}/#{@key}", JSON.generate([@url]), 'CONTENT_TYPE' => 'application/json'
    last_response.should be_ok
    JSON.parse(last_response.body)['stored'].should == 1
    @node.peers.size.should == 1
    @node.hosts.size.should == 1
  end

  it 'renders a list of hosts (FIND_VALUE)' do
    get "#{app.class::Path}/#{@key}"
    last_response.should be_ok
    last_response.body.strip.should == JSON.generate({key: @key.to_s, hosts: [@host.to_hash], peers: [@self_peer.to_hash]})
  end
end
