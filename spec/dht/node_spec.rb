require 'spec_helper'
require 'dht/node'

include DHT

describe Node do
  describe 'A one-node network' do
    before do
      @root = Node.new 'http://0'
    end

    it 'stores a value' do
      key, value = Key.new(1), 'http://foo'
      @root.store key, value
      @root.values_for(key).should == [[value], []]
    end

    it 'bootstraps a new node' do
      @node = Node.new 'http://1'
      @node.bootstrap @root

      @node.peers.to_a.should == [@root]
      @root.peers.to_a.should == [@node]
    end
  end

  describe 'A two-node network' do
    before do
      @root = Node.new 'http://0'
      @node = Node.new 'http://1'
      @node.bootstrap @root

      @node.peers.to_a.should == [@root]
    end

    it 'bootstraps a new node' do
      @node_2 = Node.new 'http://2'
      @node_2.bootstrap @root

      @node_2.peers.to_a.should == [@node, @root]
      @root.peers.to_a.should == [@node_2, @node]
    end

    it 'stores and retrieve local values' do
      key, value = Key.for_content('foo'), 'bar'
      @root.store( key, value ).should be_true
      @root.values.to_a.should == [{key => value}]

      values, peers = @root.values_for( key, @node )
      values.to_a.should == [value]
      peers.to_a.should == [@node]
    end

    it 'stores values across the network' do
      key, value = Key.for_content('foo'), 'bar'
      @root.store!( key, value ).should == 2
      @root.values.to_a.should == [{key => value}]
      @node.values.to_a.should == [{key => value}]
    end
  end

  describe 'A node on a 5x5 network' do
    before do
      @nodes = (0...5).map  do |n|
        url = "http://#{(n+2)**2}"  # fuzzed for maximum key distribution (i.e. 24, below)
        Node.new( url ) { |n|
          n.values.max_keys = 5
        }
      end
      @root = @nodes.first
      @nodes[1..-1].each { |node|  node.bootstrap @root }
    end

    it 'stores and retrieves values at capacity' do
      stored = 0
      25.times do |n|
        stored += 1  if @root.store!( n, n, 5 ).nonzero?
      end
      stored.should >= 24
    end
  end
end
