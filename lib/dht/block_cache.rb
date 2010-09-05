require 'dht/block'

module DHT

class BlockCache
  attr_accessor :key, :dir, :max_bytes
  attr_reader :blocks

  def initialize( key, dir, max_bytes = nil )
    @key, @max_bytes = key, max_bytes
    @hosts = Hash.new { |h, k|  h[k] = Set.new }
    refresh
  end

  def inspect
    out = StringIO.new
    for key, urls in @hosts.sort_by { |peer|  peer.key.distance_to(self.key) }
      out.puts "  #{key.inspect} (#{'%040x' % key.distance_to(self.key)}): #{urls.join(', ')}"
    end
    out.string
  end

  def []( key )
    @hosts[key]
  end

  def <<( key )
    @hosts[key] << key
  end

  def refresh
  end
end

end
