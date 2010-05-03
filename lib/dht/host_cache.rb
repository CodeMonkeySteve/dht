require 'dht/host'

module DHT

class HostCache
  attr_accessor :key, :max_keys
  attr_reader :hosts

  delegate :==, :eql?, :[], :to => :hosts

  def initialize( key, max_keys = nil )
    @key, @max_keys = key, max_keys
    @hosts = Hash.new { |h, k|  h[k] = [] }
  end

  def touch( key, host )
    host.touch
    @hosts[key].delete host
    @hosts[key].unshift host

    if @max_keys
      remove = @hosts.keys.sort_by { |k|  k.distance_to(self.key)  }.slice(@max_keys..-1)
      return true  unless remove && remove.any?

      remove.each { |k|  @hosts.delete(k) }
      return !remove.include?( key )
    end

    true
  end

  def inspect
    out = StringIO.new
    for key, hosts in @hosts.sort_by { |key, urls|  key.distance_to(self.key) }
      out.puts "  #{key.inspect} (#{'%040x' % key.distance_to(self.key)}): #{hosts.to_a.map(&:inspect).join(', ')}"
    end
    out.string
  end
end

end