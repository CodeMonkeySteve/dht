require 'dht/key'

module DHT

class ValueCache
  Type = String
  TypeName = 'value'.freeze
  class Entry
    attr_accessor :key, :value, :distance
    attr_reader :active_at

    delegate :==, :eql?, :<=>, :to => :key

    def initialize( key, value, distance )
      @key, @value, @distance = key, value, distance
    end

    def to_hash
      { :key => key.to_s, :value => value }
    end

    def touch
      @active_at = Time.now
      self
    end
  end

  attr_accessor :key, :max_keys
  attr_reader :entries, :by_key

#  delegate :==, :eql?, :[], :to => :entries

  def initialize( key, max_keys = nil )
    @key, @max_keys = key, max_keys
    @entries = []
    @by_key = Multimap.new
  end

  def inspect
    out = StringIO.new
    for key, entry in @by_key
      out.puts "  #{key.inspect} (#{'%040x' % entry.distance}): #{entry.value}"
    end
    out.string
  end

#   def from_hash( hash )
#     hash.each { |k, v|  self.touch( k, v ) }
#   end

  def to_a
    @entries.map(&:to_hash)
  end

  def touch( key, value )
    (entry = add( key, value ))
    entry.touch  if entry
    entry
  end

  def add( key, value )
    entry = @by_key[key].find { |e| e.value == value }
    return entry  if entry

    entry = Entry.new( key, value, key.distance_to(self.key) )
    @entries << entry
    if @max_keys && (@entries.size > @max_keys)
      removed = @entries.sort! { |a, b| a.distance <=> b.distance }.slice!(@max_keys..-1)
      return nil  if removed.include? entry
    end
    @by_key[key] = entry
    $log.puts '-'*100, 'Values:', self.inspect, '-'*100
    entry
  end
end

end