require 'dht/cache'
require 'dht/host'

module DHT

class HostCache < Cache

  def to_hash
    self.by_key.map { |k, h|  h.to_hash(:key => k.to_s) }
  end

end

end