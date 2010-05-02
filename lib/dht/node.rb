require 'set'
require 'dht/peer_table'

module DHT

class Node < Peer
  attr_reader :peers, :values
  delegate :key, :key=, :buckets, :to => :peers

  def initialize( key, cache_size = nil )
    @peers = PeerTable.new key
    @values = Hash.new { |h, k|  h[k] = Set.new }
    @cache_size = cache_size
    super key
    yield self  if block_given?
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
    self.key.inspect
  end

  def dump
    puts "#{key.inspect}:"
    @values.sort_by { |k, v|  k.distance_to(self.key) }.each { |k, v| puts "  #{k.inspect} (#{'%040x' % k.distance_to(self.key)}): #{v.to_a.join(', ')}" }
#    puts peers.inspect
  end

  # outgoing peer interface
  def ping!( peer )
    peers.touch peer
    peer.ping_from self
  end

  def store!( key, val, redundancy = nil )
    redundancy += 1  if redundancy
    copies = 0
    peers = [self] + peers_for!( key )
    for peer in peers
      copies += 1  if peer.store( key, val )
      break  if redundancy && (copies >= redundancy)
    end
    copies
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
    [ values.to_a, peers ]
  end

  # incoming peer interface
  # PING
  def ping_from( peer )
    peers.touch peer
  end

  # STORE
  def store( key, val )
    key = Key.new(key)  unless Key === key
    @values[key] << val
    if @cache_size
      remove = @values.keys.sort_by { |k|  k.distance_to(self.key)  }.slice(@cache_size..-1)
      return true  unless remove && remove.any?

      remove.each { |k|  @values.delete(k) }
      return !remove.include?( key )
    end

    true
  end

  # FIND_NODE
  def peers_for( key )
    key = Key.new(key)  unless Key === key
    peers.nearest_to( key ).to_a
  end

  # FIND_VALUE
  def values_for( key )
    key = Key.new(key)  unless Key === key
    [ (@values[key].to_a || []), peers_for( key ) ]
  end

protected
  def find_peers_for!( key, &peers_for )
    key = Key.new(key)  unless Key === key
    tried = Set.new
    peers = peers_for.call self
    until peers.empty?
      peer = peers.shift

      new_peers = peers_for.call peer
      self.peers.touch peer
      tried.add peer

      new_peers.delete self
      new_peers.reject! { |p|  tried.include?(p)  }
      peers = (peers + new_peers).sort_by { |p|  p.key.distance_to(key) }
    end
    tried.to_a
  end
end

end
