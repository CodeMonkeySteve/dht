require 'spec_helper'
require 'dht/node'

include DHT

describe Node do
  describe 'A one-node network' do
    before do
      @root = Node.new 'http://node0/'
    end

    it 'stores a host' do
      key, host = Key.new(1), Host.new('http://nowhere.invalid/')
      @root.store key, host.url
      @root.hosts_for(key).should == [[host], []]
    end

    it 'bootstraps a new node' do
      @node = Node.new 'http://node1/'
      @node.bootstrap @root

      @node.peers.to_a.should == [@root]
      @root.peers.to_a.should == [@node]
    end
  end

  describe 'A two-node network' do
    before do
      Timecop.freeze
      @root = Node.new 'http://node0/'
      @node = Node.new 'http://node1/'
      @node.bootstrap @root

      @node.peers.to_a.should == [@root]
    end

    it 'bootstraps a new node' do
      @node_2 = Node.new 'http://node2/'
      @node_2.bootstrap @root

      @node_2.peers.should == [@root, @node]
      @root.peers.should == [@node_2, @node]
    end

    it 'stores and retrieve local host urls' do
      key, url = Key.for_content('foo'), 'http://nowhere2.invalid/'
      host = @root.store key, url
      @root.hosts.should == [host]

      hosts, peers = @root.hosts_for( key, @node )
      hosts.should == [host]
      peers.should == [@node]
    end

    it 'stores host urls across the network' do
      key, url = Key.for_content('foo'), 'http://nowhere3.invalid/'
      @root.store!( key, url ).should == 2
      @root.hosts.to_hash.should == [{:key => key.to_s, :url => url, :active_at => Time.now}]
      @node.hosts.to_hash.should == [{:key => key.to_s, :url => url, :active_at => Time.now}]
    end
  end

  describe 'A node on a 5x5 network' do
    before do
      @nodes = (0...5).map  do |n|
        url = "http://node#{(n+10)**2}/"  # fuzzed for maximum key distribution (i.e. 24, below)
        Node.new( url ) { |n|
          n.hosts.max_keys = 5
        }
      end
      @root = @nodes.first
      @nodes[1..-1].each { |node|  node.bootstrap @root }
    end

    it 'stores and retrieves host urls at capacity' do
      stored = 0
      25.times do |n|
        stored += 1  if @root.store!( n, "http://nowhere#{n}.invalid/", 5 ).nonzero?
      end
      stored.should >= 24
    end
  end
end
