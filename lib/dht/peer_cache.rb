require 'dht/peer'

module DHT

class PeerCache
  ResultSize = 20

  attr_accessor :key, :max_peers
  attr_reader :peers

  def initialize( key, max_peers = nil )
    @key, @max_peers = key, max_peers
    @peers = []
  end

  def inspect
    out = StringIO.new
    for peer in @peers.sort_by { |peer|  peer.key.distance_to(self.key) }
      out.puts "  #{peer.key.inspect} (#{'%040x' % peer.key.distance_to(self.key)})"
    end
    out.string
  end

  def all
    @peers.to_a
  end

  def touch( peer )
    peer.touch
    @peers.delete peer
    @peers.unshift peer
  end

  def nearest_to( key )
    peers = @peers.sort_by { |peer|  peer.key.distance_to(key)  }[0...ResultSize]
  end
end

end