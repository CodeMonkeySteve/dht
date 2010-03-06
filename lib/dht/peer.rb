require 'dht/key'

module DHT

class Peer
def save! ; end  # FIXME: for factory_girl

  attr_accessor :key, :url, :updated_at

  def initialize( url = nil, key = nil )
    self.key = key.nil? || key.kind_of?(Key) ? key : Key.new(key)
    self.url = url
    @updated_at = nil
  end

  def url=( url )
    @url = url
    self.key ||= Key.for_content(@url)  if @url
  end

  # peer interface

  # PING
  def ping_from( peer )
    raise NotImplemenedError
  end

  # STORE
  def store( key, val )
    raise NotImplemenedError
  end

  # FIND_NODE
  def peers_for( key )
    raise NotImplemenedError
  end

  # FIND_VALUE
  def values_for( key )
    raise NotImplemenedError
  end
end

end