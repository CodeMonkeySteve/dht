require 'dht/key'

module DHT

class Peer
def save! ; end  # FIXME: for factory_girl

  attr_reader :url, :key, :active_at

  def initialize( url )
    @url = Addressable::URI.parse(url)
    @url.port = nil  if @url.port == 80
    @url.path = '/'  if @url.path.blank?
    host_with_port = @url.host
    host_with_port += ":#{@url.port}"  if @url.port
    @key = Key.for_content(host_with_port + @url.path)
    @active_at = nil
  end

  def touch
    @active_at = Time.now
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