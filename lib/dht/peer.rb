require 'dht/key'
require 'dht/value_cache'
require 'addressable/uri'

module DHT

class Peer
  attr_reader :url, :key, :active_at

  def ==( that )
    self.key == that.key
  end

  def self.from_hash( hash )
    hash = hash.symbolize_keys
    Peer.new hash[:url], hash[:active_at]
  end

  def initialize( url, active_at = nil )
    @url = (Addressable::URI === url) ? url : Addressable::URI.parse(url)
    @url.port = nil  if @url.port && (@url.port == 80)
    @url.path = '/'  if @url.path.blank?
    host_with_port = @url.host
    host_with_port += ":#{@url.port}"  if @url.port
    @key = Key.for_content(host_with_port + @url.path)
    @active_at = active_at && ((Time === active_at) ? active_at : Time.parse(active_at))
  end

  def to_hash
    { :key => @key.to_s, :url => @url.to_s, :active_at => @active_at }
  end

  def touch
    @active_at = Time.now
    self
  end

  # peer interface
  # FIND_NODE
  def peers_for( key, from_node )
    req = EventMachine::HttpRequest.new("#{url}/peers/#{key.to_s}").
          get( :head => headers(from_node) )

# FIXME: error handling
#return nil  unless req.success

    from_node.peers.touch self
    peers = JSON.parse( req.response ).map do |hash|
      peer = Peer.from_hash hash
      raise "Peer key mismatch: #{hash['url']} has key #{hash['key']}, expected #{peer.key}"  unless peer.key.to_s == hash['key']
      from_node.peers.add peer
      peer
    end
    peers
  end

  # FIND_VALUE
  def values_for( key, from_node )
    req = EventMachine::HttpRequest.new("#{url}/#{ValueCache::TypeName.pluralize}/#{key.to_s}").
          get( :head => headers(from_node) )
    values, peers = JSON.parse(req.response).values_at('values', 'peers')
    peers.map! { |hash|  Peer.new hash['url'], hash['active_at'] }
    [ values, peers ]
  end

  # STORE
  def store( key, val, from_node )
    res = EventMachine::HttpRequest.new("#{url}/#{ValueCache::TypeName.pluralize}/#{key.to_s}").
          post( :body => JSON.generate([val]), :head => headers(from_node) )
pp req
    JSON.parse req.response
  end

protected
  def headers( from_peer )
   { 'X-PEER-URL' => from_peer.url.to_s, 'Accept' => 'application/json' }
  end
end

end