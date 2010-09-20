require 'set'
require 'dht/peer_cache'
require 'dht/value_cache'
require 'dht/poller'

module DHT

class Node < Peer
  attr_reader :peers, :values

  def initialize( url )
    super
    $log.puts "Starting node at #{url}"
    @peers = PeerCache.new self.key
    @values = ValueCache.new self.key
    @poller = Poller.new(self).start
    yield self  if block_given?
  end

  def key=( key )
    key = key.kind_of?(Key) ? key : Key.new(key)
    @key = @peers.key = @values.key = key
  end

  def inspect
    self.key.inspect
  end

  def dump
    puts "#{key.inspect}:",
         "Peers: ", peers.inspect,
         "Values: ", values.inspect
  end

  def bootstrap( peer )
    @peers.add peer
    peers_for! self.key
  end

  # serialization
  def load( path )
    return false  unless File.exists?(path)
    data = JSON.parse File.read(path)
    @peers.from_hashes data['peers']
    @values.from_hash data['values']
  end

  def save( path )
    File.open(path, 'w') do |io|
      io.print JSON.generate({
        :peers => @peers.to_hashes,
        :values => @values.to_hash,
      }) + "\n"
    end
  end

  # outgoing peer interface
  def store!( key, value, redundancy = nil )
    key = Key.for_content(key.to_s)  unless Key === key
    redundancy += 1  if redundancy
    copies = 0
    peers = [self] + peers_for!( key )
    for peer in peers
      copies += 1  if peer.store( key, value )
      break  if redundancy && (copies >= redundancy)
    end
    copies
  end

  def peers_for!( key )
    find_peers_for!( key ) { |peer|  peer.peers_for( key, self )  }
  end

  def values_for!( key )
    values = Set.new
    peers = find_peers_for!( key ) do |peer|
      new_values, new_peers = *peer.values_for( key, self )
      values |= new_values
      new_peers
    end
    [ values.to_a, peers ]
  end

  # incoming peer interface
  # FIND_NODE
  def peers_for( key, from_peer = nil )
    @peers.touch from_peer  if from_peer
    key = Key.new(key)  unless Key === key
    peers.nearest_to( key ).to_a
  end

  # FIND_VALUE
  def values_for( key, from_peer = nil )
    @peers.touch from_peer  if from_peer
    key = Key.new(key)  unless Key === key
    [ @values.by_key[key].map(&:value), peers_for( key ) ]
  end

  # STORE
  def store( key, value, from_peer = nil )
    @peers.touch from_peer  if from_peer
    key = Key.new(key)  unless Key === key
    @values.touch key, value
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
