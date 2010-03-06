require 'spec_helper'
require 'dht/node'

include DHT

describe Node do
  before do
    @root = Node.new( 'root', 0 )
  end

  it 'bootstraps a new node' do
    node = Node.new( 'new', 1 )
    node.bootstrap @root

    @root.buckets[0].peers.should == [node]
    @root.buckets[1..-1].each { |b|  b.should be_empty }

    node.buckets[0].peers.should == [@root]
    node.buckets[1..-1].each { |b|  b.should be_empty }
  end
end
