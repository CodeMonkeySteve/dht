require 'key'

module DHT

class Peer
def save! ; end  # FIXME: for factory_girl

  attr_reader :id, :url
  attr_accessor :updated_at

  def initialize( url = nil )
    self.url = url
    @updated_at = nil
  end

  def url=( url )
    @url = url
    @id = Key.for_content(@url)  if @url
  end

  def ping
true
  end

  def store( key, val )
    raise NotImplemenedError
  end

  def value( key )
    raise NotImplemenedError
  end

  def peers_for( key )
    raise NotImplemenedError
  end
end

end
