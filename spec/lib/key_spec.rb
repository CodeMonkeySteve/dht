require 'spec_helper'
require 'key'

include DHT

describe Key do
  before(:all) do
    @key = Key.new "\v\356\307\265\352?\017\333\311]\r\324\177<[\302u\332\0000"
  end

  it 'initializes from a hex String' do
    Key.new('0beec7b5ea3f0fdbc95d0dd47f3c5bc275da0030').should == @key
  end

  it 'converts to an Integer' do
    @key.to_i.should == 68123873083688143418383284816464454849230667824
  end

  it 'computes distance to another key' do
    k = @key.to_i
    for x in (0..15)
      @key.distance_to( k + x ).should == x
    end
    @key.distance_to( k + 0b10000 ).should == 0b1110000
    @key.distance_to( k | 0b11111111 ).should == 0b11001111
  end
end

