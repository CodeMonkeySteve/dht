require 'spec_helper'
require 'dht/peer_table'

include DHT

describe PeerTable do
  before do
    @key = Key.new(0)
    @table = PeerTable.new @key
    @buckets = @table.instance_variable_get(:@buckets)
  end

  it 'errors with self key' do
  end

  it 'computes the correct bucket index' do
    @table.send( :bucket_index_for, @key.to_i ).should be_nil
    for bit in 0...PeerTable::NumBuckets
      @table.send( :bucket_index_for, @key.to_i ^ (1 << bit) ).should == bit
    end
  end

  describe 'with lots of peers' do
    before(:each) do
      @peers = (1..(PeerTable::NumBuckets*2)).map  do |n|
        peer = Peer.new "http://#{n}"
        stub(peer).key {  Key.new(n)  }
        @table.touch peer
      end
    end

    it 'adds peers to the correct buckets (and queues)' do
      @buckets[0].peers.should == @peers[0,1]
      @buckets[1].peers.should == @peers[1,2]
      @buckets[2].peers.should == @peers[3,4]
      @buckets[3].peers.should == @peers[7,8]
      @buckets[4].peers.should == @peers[15,16]
      @buckets[5].peers.should == @peers[31,20]
      @buckets[5].instance_variable_get(:@queue).should == @peers[51,12]
      @buckets[6].peers.should == @peers[63,20]
      @buckets[6].instance_variable_get(:@queue).should == @peers[83,44]

      for i in (9...(Key::Size*8))
        @buckets[i].peers.should be_empty
        @buckets[i].instance_variable_get(:@queue).should be_empty
      end
    end

    it 'returns the nearest peer' do
      @table.nearest_to( Key.new(0x01) ).should == @peers.values_at(0,2,1,4,3,6,5,8,7,10,9,12,11,14,13,16,15,18,17,20)
      @table.nearest_to( Key.new(0x02) ).should == @peers.values_at(1,2,0,5,6,3,4,9,10,7,8,13,14,11,12,17,18,15,16,21)
    end
  end
end

describe DHT::PeerTable::Bucket do
  before(:each) do
    @bucket = PeerTable::Bucket.new
  end

  it 'adds new peers' do
    peers = (0..3).map {  Factory(:peer)  }
    peers.each { |peer|  @bucket.touch peer  }
    @bucket.instance_variable_get(:@peers).should == peers
  end

  it 'stores extra peers in the queue' do
    peers = (0..(PeerTable::Bucket::Size+5)).map {  @bucket.touch( Factory(:peer) )  }
    @bucket.instance_variable_get(:@peers).should == peers.slice(0...PeerTable::Bucket::Size)
    @bucket.instance_variable_get(:@queue).should == peers.slice(PeerTable::Bucket::Size..-1)
  end
end
