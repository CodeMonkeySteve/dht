require 'dht/key'
require 'dht/value_cache'

module DHT

class Peer
def save! ; end  # FIXME: for factory_girl

  attr_reader :url, :key, :active_at

  def self.from_hash( hash )
    Peer.new hash[:url], hash[:active_at]
  end

  def initialize( url, active_at = nil )
    @url = (Addressable::URI === url) ? url : Addressable::URI.parse(url)
    @url.port = nil  if @url.port && (@url.port == 80)
    @url.path = '/'  if @url.path.blank?
    host_with_port = @url.host
    host_with_port += ":#{@url.port}"  if @url.port
    @key = Key.for_content(host_with_port + @url.path)
    @active_at = active_at
  end

  def to_hash
    { :key => @key.to_s, :url => @url.to_s, :active_at => @active_at }
  end

  def touch
    @active_at = Time.now
    self
  end

  # peer interface
  # PING
  def ping_from( peer )
    res = EventMachine::HttpRequest.new("#{peer.url}/").head
p res
    res
  end

  # STORE
  def store( key, val )
    res = EventMachine::HttpRequest.new("#{peer.url}/#{ValueCache::TypeName}/#{key.to_s}").post( :body => JSON.generate([val]) )
p res
    JSON.parse res.body
  end

  # FIND_NODE
  def peers_for( key )
    res = EventMachine::HttpRequest.new("#{peer.url}/peers/#{key.to_s}").get
p res
    JSON.parse(res.body)['peers']
  end

  # FIND_VALUE
  def values_for( key )
    res = EventMachine::HttpRequest.new("#{peer.url}/#{ValueCache::TypeName}/#{key.to_s}").post( :body => JSON.generate([val]) )
p res
    JSON.parse(res.body).values_at('values', 'peers')
  end
end

end