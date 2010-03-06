require 'set'
require 'dht/peer_table'


module DHT

class Node < Peer
  Redundancy = 10

  attr_reader :peers
  delegate :key, :key=, :buckets, :to => :peers

  def initialize( url, key = nil )
    @peers = PeerTable.new nil
    @values = Hash.new { |h, k|  h[k] = [] }
    super
  end

  def bootstrap( peer )
    ping! peer
    refresh peer
  end

  def refresh( peer )
    peers.each_key_to_refresh( peer.key ) { |key|  peers_for! key  }
  end

  def inspect
    out = StringIO.new
    out.puts "Node #{url.inspect} (#{key.inspect})"
    out << "Peers:\n" << peers.inspect
    out << "Values:\n" << @values.map { |k, v| "#{k.inspect}: #{v.inspect}\n" }.join('')
    out.string
  end

  # outgoing peer interface
  def ping!( peer )
    peers.touch peer
    peer.ping_from self
  end

  def store!( key, val )
  end

  def peers_for!( key )
    key = Key.new(key)  unless Key === key
    peers, tried = peers_for( key ), Set.new

    until peers.empty?
      peer = peers.shift
      tried.add peer

      res = peer.peers_for( key )
      res.reject! { |peer|  tried.include?(peer)  }
      peers = (peers + res).sort_by { |p|  p.key.distance_to(key) }
    end
  end

  def values_for!( key )
  end

  # incoming peer interface
  # PING
  def ping_from( peer )
    peers.touch peer
  end

  # STORE
  def store( key, val )
    key = Key.new(key)  unless Key === key

    # FIXME: sized cache store
    @values[key] << val
    true
  end

  # FIND_NODE
  def peers_for( key )
    key = Key.new(key)  unless Key === key
    peers.nearest_to key
  end

  # FIND_VALUE
  def values_for( key )
    key = Key.new(key)  unless Key === key
    @values[key] || peers_for(key)
  end
end

end
