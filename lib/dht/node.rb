require 'set'
require 'dht/peer_cache'
require 'dht/host_cache'

module DHT

class Node < Peer
  attr_reader :peers, :hosts

  def initialize( url )
    super
    @peers = PeerCache.new self.key
    @hosts = HostCache.new self.key
    yield self  if block_given?
  end

  def key=( key )
    key = key.kind_of?(Key) ? key : Key.new(key)
    @key = @peers.key = @hosts.key = key
  end

  def inspect
    self.key.inspect
  end

  def dump
    puts "#{key.inspect}:",
         "Peers: ", peers.inspect,
         "Hosts: ", hosts.inspect
  end

  def bootstrap( peer )
    ping! peer
    peers_for! self.key
  end

  # outgoing peer interface
  def ping!( peer )
    return  unless peer.ping_from(self)
    peers.touch peer
  end

  def store!( key, val, redundancy = nil )
    key = Key.for_content(key.to_s)  unless Key === key
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

  def hosts_for!( key )
    hosts = Set.new
    peers = find_peers_for!( key ) do |peer|
      new_hosts, new_peers = *peer.hosts_for( key )
      hosts |= new_hosts
      new_peers
    end
    [ hosts.to_a, peers ]
  end

  # incoming peer interface
  # PING
  def ping_from( peer )
    peers.touch peer
    true
  end

  # STORE
  def store( key, host )
    key = Key.new(key)  unless Key === key
    host = Host.new(host)  unless Host === host
    @hosts.touch key, host
  end

  # FIND_NODE
  def peers_for( key )
    key = Key.new(key)  unless Key === key
    peers.nearest_to( key ).to_a
  end

  # FIND_VALUE
  def hosts_for( key )
    key = Key.new(key)  unless Key === key
    [ (@hosts[key].to_a || []), peers_for( key ) ]
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
