require 'spec_helper'
require 'dht/key'

include DHT

describe Key do
  before do
    @key = Key.new "\v\xEE\xC7\xB5\xEA?\x0F\xDB\xC9]\r\xD4\x7F<[\xC2u\xDA\x000"
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

