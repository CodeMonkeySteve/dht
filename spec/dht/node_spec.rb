require 'spec_helper'
require 'dht/node'

include DHT

describe Node do
  describe 'A one-node network' do
    before do
      @root = Node.new 0
    end

    it 'stores a value' do
      key = Key.new 1
      @root.store key, 'foo'
      @root.values_for(key).should == [['foo'], []]
    end

    it 'bootstraps a new node' do
      @node = Node.new 1
      @node.bootstrap @root
      @node.peers.all.should == [@root]

      @root.peers.all.should == [@node]
    end
  end

  describe 'A two-node network' do
    before do
      @root = Node.new 0
      @node = Node.new 1
      @node.bootstrap @root
      @node.peers.all.should == [@root]
    end

    it 'bootstraps a new node' do
      @node_2 = Node.new 2
      @node_2.bootstrap @root
      @node_2.peers.all.should == [@root, @node]

      @root.peers.all.should == [@node, @node_2]
    end

    it 'stores and retrieve local values' do
      key, val = Key.for_content('foo'), 'bar'
      @root.store( key, val ).should be_true
      @root.values.should == {key => Set[val]}

      vals, peers = @root.values_for( key )
      vals.to_a.should == [val]
      peers.to_a.should == [@node]
    end

    it 'stores values across the network' do
      key, val = Key.for_content('foo'), 'bar'
      @root.store!( key, val ).should == 2
      @root.values.should == {key => Set[val]}
      @node.values.should == {key => Set[val]}
    end
  end

  describe 'A node on a 5x5 network' do
    before do
      @nodes = (0...5).map { |n|  Node.new( Key.for_content(n.to_s), 5 )  }
      @root = @nodes.first
      @nodes[1..-1].each { |node|  node.bootstrap @root  }
    end

    it 'stores and retrieves values at capacity' do
      stored = 0
      25.times do |n|
        key = Key.for_content(n.to_s)
        stored += 1  if @root.store!( key, n, 5 ).nonzero?
      end
      stored.should >= 23
    end
  end
end
