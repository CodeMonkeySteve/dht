require 'spec_helper'
require 'peer'

include DHT

describe Peer do
  it 'generates the id from the url' do
    peer = Peer.new 'http://localhost:3000/'
    peer.id.should == Key.new('c941ad20dc843d199a8832622748bcf0b460ca68')
  end
end