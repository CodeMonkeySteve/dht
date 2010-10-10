require 'dht/cache'
require 'dht/peer'

module DHT

class PeerCache < Cache
  def add( peer, key = nil )
    key ||= peer.key
    key.present? && (key != self.key) && super( peer, key )
  end

  def nearest_to( key )
    self[0...ResultSize]
  end
end

end