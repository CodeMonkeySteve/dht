require 'spec_helper'
require 'dht/node'

include DHT

describe Node do
  describe 'A node on a 2-node network'
  before do
    @root = Node.new 0
    @node = Node.new 1
    @node.bootstrap @root
  end

  it 'bootstraps a new node' do
    @root.buckets[0].peers.should == [@node]
    @root.buckets[1..-1].each { |b|  b.should be_empty }

    @node.buckets[0].peers.should == [@root]
    @node.buckets[1..-1].each { |b|  b.should be_empty }
  end

  it 'stores and retrieve local values' do
    key, val = Key.for_content('foo'), 'bar'
    @root.store( key, val ).should be_true
    vals, peers = @root.values_for( key )
    vals.to_a.should == [val]
    peers.to_a.should == [@node]
  end

end
