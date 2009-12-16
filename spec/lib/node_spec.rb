require 'spec_helper'
require 'node'

include DHT

describe Node do
  before(:each) do
    @root = Node.new 'root'
    stub(@root).id {  Key.new(0)  }

    @root.store Key.for_content('foo'), 'bar'
    @buckets = @root.instance_variable_get(:@peers).instance_variable_get(:@buckets)
  end

  it 'bootstraps a new node' do
    node = Node.new 'new'
    stub(node).id {  Key.new(1)  }
    node.bootstrap @root

    @buckets[0].peers.hould == [node]
    @buckets[1..-1].flatten.should be_empty

    buckets = node.instance_variable_get(:@peers).instance_variable_get(:@buckets)
    buckets[0].should == [@root]
    buckets[1..-1].flatten.should be_empty
  end
end
