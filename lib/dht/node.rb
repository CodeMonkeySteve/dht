require 'set'
require 'dht/peer_table'

module DHT

class Node < Peer
  Redundancy = 10

  attr_reader :peers
  delegate :key, :key=, :buckets, :to => :peers

  def initialize( key )
    @peers = PeerTable.new key
    @values = Hash.new { |h, k|  h[k] = Set.new }
    super
  end

  def bootstrap( peer )
    ping! peer
    refresh peer
  end

  def refresh( peer )
    peers.each_key_to_refresh( peer.key ) do |key|
      peers_for! key
    end
  end

  def inspect
    out = StringIO.new
    out.puts "Node #{key.inspect}"
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
    copies = 0
    peers = peers_for!( key )
    for peer in peers
      copies += 1  if peer.store( key, val )
      break  if copies == Redundancy
    end
    copies
  end

  def find_peers_for!( key, &peers_for )
    key = Key.new(key)  unless Key === key
    tried = Set.new
    peers = peers_for.call self

    until peers.empty?
      peer = peers.shift
      tried.add peer
      new_peers = peers_for.call peer
      new_peers.reject! { |p|  tried.include?(p)  }
      peers = (peers + new_peers).sort_by { |p|  p.key.distance_to(key) }
    end
    peers
  end

  def peers_for!( key )
    find_peers_for!( key ) { |peer|  peer.peers_for( key )  }
  end

  def values_for!( key )
    values = Set.new
    peers = find_peers_for!( key ) do |peer|
      new_values, new_peers = *peer.values_for( key )
      values |= new_values
      new_peers
    end
    [ values, peers ]
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
    peers.nearest_to( key )
  end

  # FIND_VALUE
  def values_for( key )
    key = Key.new(key)  unless Key === key
    [ (@values[key] || []), peers_for( key ) ]
  end
end


end
