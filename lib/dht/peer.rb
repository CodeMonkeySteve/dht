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
    raise NotImplementedError
  end

  # FIND_VALUE
  def values_for( key, from_node )
    raise NotImplementedError
  end

  # STORE
  def store( key, val, from_node )
    raise NotImplementedError
  end
end

end