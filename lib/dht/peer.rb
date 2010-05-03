require 'dht/key'

module DHT

class Peer
def save! ; end  # FIXME: for factory_girl

  attr_reader :url, :key, :active_at

  def initialize( url )
    @url, @key = url, Key.for_content(url)
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