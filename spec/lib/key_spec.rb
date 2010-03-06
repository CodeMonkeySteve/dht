require 'spec_helper'
require 'dht/key'

describe DHT::Key do
  before do
    @key = DHT::Key.new "\v\356\307\265\352?\017\333\311]\r\324\177<[\302u\332\0000"
  end

  it 'initializes from a hex String' do
    Key.new('0beec7b5ea3f0fdbc95d0dd47f3c5bc275da0030').should == @key
  end

  it 'converts to an Integer' do
    @key.to_i.should == 68123873083688143418383284816464454849230667824
  end

  it 'computes distance to another key' do
    k = @key.to_i

    @key.distance_to( k ).should == 0
    for bit in 0...(Key::Size*8)
      mask = 1 << bit
      @key.distance_to( k ^ mask ).should == mask
    end
  end
end

