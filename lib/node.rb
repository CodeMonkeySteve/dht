require 'peer_table'
require 'set'

module DHT

class Node < Peer
  Redundancy = 10

  def initialize( url )
    super
    @peers = PeerTable.new self.id
    @values = {}
  end

  def bootstrap( peer )
  end

  # network interface
  def []( key )
    key = Key.new(key)  unless Key === key
    peers, tried = peers_for(key), Set.new
    best = peers.first
    until peers.empty?
      peer = peers.shift
      tried.add peer

      res = peer.value( key )
      return res  unless Array === res

      res.reject! { |peer|  tried.include?(peer)  }
      peers = (peers + res).sort_by { |p|  p.id.distance_to(key) }
      best = peers.first  if peers.first.id.distance_to(key) < best.id.distance_to(key)
    end
  end

  def []=( key, val )
  end

  # peer interface
  def store( key, val )
    key = Key.new(key)  unless Key === key

    # FIXME: sized store
    @values[key] = val
    true
  end

  def value( key )
    key = Key.new(key)  unless Key === key
    if val = @values[key]
      return val
    end

    peers_for key
  end

  def peers_for( key )
    key = Key.new(key)  unless Key === key
    @peers.nearest_to(key)
  end

  # debug
  def dump
    out = StringIO.new
    out.puts "Node #{url.inspect} (#{id.inspect})"
    out << "Peers:\n" << @peers.inspect
    out << "Values:\n" << @values.map { |k, v| "#{k.inspect}: #{v.inspect}\n" }.join('')
    out.string
  end
end

end