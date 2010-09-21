require 'dht/peer'

module DHT

class PeerCache
  ResultSize = 20

  attr_accessor :key, :max_peers
  attr_reader :peers

  delegate :to_a, :to => :peers

  def initialize( key, max_peers = nil )
    @key, @max_peers = key, max_peers
    @peers = []
  end

  def inspect
    out = StringIO.new
    for peer in @peers.sort_by { |peer|  peer.key.distance_to(self.key) }
      out.puts "  #{peer.url} #{peer.key.inspect} (#{'%040x' % peer.key.distance_to(self.key)})"
    end
    out.string
  end

  def from_hashes( hashes )
    @peers = hashes.map { |hash|  Peer.from_hash(hash) }
  end

  def to_hash
    @peers.map(&:to_hash)
  end

  def add( peer )
    return  if peer.key == self.key
    if @peers.include? peer
      @peers.delete peer
      @peers.unshift peer
    else
      @peers.unshift peer
      $log.puts '-'*100, 'Peers:', self.inspect, '-'*100
    end
    peer
  end

  def touch( peer )
    add peer
    peer.touch
  end

  def nearest_to( key )
    peers = @peers.sort_by { |peer|  peer.key.distance_to(key)  }[0...ResultSize]
  end
end

end