require 'set'
require 'dht/peer_cache'
require 'dht/host_cache'
require 'dht/poller'

module DHT

class Node < Peer
  attr_reader :peers, :hosts

  def initialize( url )
    super
    $log.puts "Starting node at #{url}"
    @peers = PeerCache.new self.key
    @hosts = HostCache.new self.key
    @poller = Poller.new(self).start
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
    @peers.add peer
    peers_for! self.key
  end

  # serialization
  def load( path )
    return false  unless File.exists?(path)
    data = JSON.parse File.read(path)
    @peers.from_hashes data['peers']
    @hosts.from_hash data['hosts']
  end

  def save( path )
    File.open(path, 'w') do |io|
      io.print JSON.generate({
        :peers => @peers.to_hashes,
        :hosts => @hosts.to_hash,
      }) + "\n"
    end
  end

  # outgoing peer interface
  def store!( key, url, redundancy = nil )
    key = Key.for_content(key.to_s)  unless Key === key
    redundancy += 1  if redundancy
    copies = 0
    peers = peers_for!( key )
    peers << self  unless peers.include?(self)
    for peer in peers
      copies += 1  if peer.store( key, url )
      break  if redundancy && (copies >= redundancy)
    end
    copies
  end

  def peers_for!( key )
    find_peers_for!( key ) { |peer|  peer.peers_for( key, self )  }
  end

  def hosts_for!( key )
    hosts = Set.new
    peers = find_peers_for!( key ) do |peer|
      new_hosts, new_peers = *peer.hosts_for( key, self )
      hosts |= new_hosts
      new_peers
    end
    hosts.each { |host|  @hosts.add( host, key )  }
    [ hosts.to_a, peers ]
  end

  # incoming peer interface
  # FIND_NODE
  def peers_for( key, from_peer = nil )
    @peers.touch from_peer  if from_peer
    key = Key.new(key)  unless Key === key
    peers.nearest_to( key )
  end

  # FIND_VALUE
  def hosts_for( key, from_peer = nil )
    @peers.touch from_peer  if from_peer
    key = Key.new(key)  unless Key === key
    [ @hosts.by_key[key], peers_for( key ) ]
  end

  # STORE
  def store( key, url, from_peer = nil )
    @peers.touch from_peer  if from_peer
    key = Key.new(key)  unless Key === key
    @hosts.touch Host.new(url), key
  end

protected
  def find_peers_for!( key, &peers_for )
    key = Key.new(key)  unless Key === key
    tried = Set.new [self]
    peers = peers_for.call self
    until peers.empty?
      peer = peers.shift

      new_peers = peers_for.call peer
      self.peers.touch peer
      tried.add peer

      new_peers.map! { |p|  self.peers.add(p) }
      new_peers.reject! { |p|  p.blank? || tried.include?(p)  }

      peers += new_peers
      peers.uniq!
      peers = peers.sort_by &:distance
    end
    tried.to_a
  end
end

end
