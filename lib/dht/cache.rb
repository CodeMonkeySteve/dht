module DHT

class Cache < Array
  ResultSize = 20

  attr_accessor :key, :max_keys, :by_key

  def initialize( key, max_keys = nil )
    @key, @max_peers = key, max_keys
    @by_key = Multimap.new
  end

  def inspect
    out = StringIO.new
    for key, obj in @by_key
      out.puts "  #{key.inspect}: #{obj.inspect}"
    end
    out.string
  end

  def to_hash
    self.map(&:to_hash)
  end

  def add( obj, key = nil )
    key ||= obj.key
    cur = @by_key[key].find { |o|  obj == o  }
    return cur  if cur

    obj.distance ||= key.distance_to(self.key)
    return  unless cache( obj )
    @by_key[key] = obj
    $log.puts '-'*100, obj.class.name.pluralize+':', self.map(&:url).map(&:to_s), '-'*100
    obj
  end

  def touch( obj, key = nil )
    add( obj, key ) && obj.touch
  end

protected
  def cache( obj )
    self.<< obj
    return nil  if @max_keys && (self.size > @max_keys) && self.slice!( @max_keys..-1 ).include?( obj )
    obj
  end

  def <<( obj )
    super
    self.sort!
  end
end

end