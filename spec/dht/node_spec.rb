require 'spec_helper'
require 'dht/node'

include DHT

describe Node do
  describe 'A one-node network' do
    before do
      @root = Node.new 'http://0'
    end

    it 'stores a host' do
      key, host = Key.new(1), Host.new('http://foo')
      @root.store key, host
      @root.hosts_for(key).should == [[host], []]
    end

    it 'bootstraps a new node' do
      @node = Node.new 'http://1'
      @node.bootstrap @root
      @node.peers.all.should == [@root]

      @root.peers.all.should == [@node]
    end
  end

  describe 'A two-node network' do
    before do
      @root = Node.new 'http://0'
      @node = Node.new 'http://1'
      @node.bootstrap @root
      @node.peers.all.should == [@root]
    end

    it 'bootstraps a new node' do
      @node_2 = Node.new 'http://2'
      @node_2.bootstrap @root
      @node_2.peers.all.should == [@node, @root]

      @root.peers.all.should == [@node_2, @node]
    end

    it 'stores and retrieve local hosts' do
      key, host = Key.for_content('foo'), Host.new('http://bar')
      @root.store( key, host ).should be_true
      @root.hosts.should == {key => [host]}

      hosts, peers = @root.hosts_for( key )
      hosts.to_a.should == [host]
      peers.to_a.should == [@node]
    end

    it 'stores hosts across the network' do
      key, host = Key.for_content('foo'), Host.new('http://bar')
      @root.store!( key, host ).should == 2
      @root.hosts.should == {key => [host]}
      @node.hosts.should == {key => [host]}
    end
  end

  describe 'A node on a 5x5 network' do
    before do
      @nodes = (0...5).map  do |n|
        url = "http://#{(n+2)**2}"  # fuzzed for maximum key distribution (i.e. 24, below)
        Node.new( url ) { |n|
          n.hosts.max_keys = 5
        }
      end
      @root = @nodes.first
      @nodes[1..-1].each { |node|  node.bootstrap @root  }
    end

    it 'stores and retrieves hosts at capacity' do
      stored = 0
      25.times do |n|
        stored += 1  if @root.store!( n, n, 5 ).nonzero?
      end
      stored.should >= 24
    end
  end
end
