require 'dht/peer'

module DHT

class PeerTable
  NumBuckets = Key::Size * 8
  attr_accessor :key
  attr_reader :buckets

  def initialize( key )
    @key = key.kind_of?(Key) ? key : Key.new(key)
    @buckets = (0...NumBuckets).map {  Bucket.new  }
  end

  def inspect
    return [].inspect  if @buckets.all? { |b|  b.empty? }
    out = StringIO.new
    @buckets.each_with_index do  |bucket, x|
      next  if bucket.peers.empty?
      out.print( '[%03i]' % x )
      for peer in bucket.peers
        out.puts "\t#{peer.key.inspect} (d:#{peer.key.distance_to(@key)})"
      end
      queue = bucket.instance_variable_get(:@queue)
      out.puts "\t+#{queue.size}"  if queue.any?
    end
    out.string
  end

  def nearest_to( key )
    peers = @buckets.map { |b| b.peers }.flatten.sort_by { |peer|  peer.key.distance_to(key)  }[0...Bucket::Size]
  end

  def touch( peer )
    bucket_for( peer.key ).touch( peer )
  end

  def each_key_to_refresh( key )
    for idx in bucket_index_for( key )...NumBuckets
      mask = 1 << idx
      rand_key = @key.to_i ^ mask ^ rand(mask)
raise "Bad key: #{rand_key.inspect}"  unless bucket_index_for(rand_key) == idx
      yield rand_key
    end
  end


  Log_2 = Math.log(2)
  def bucket_index_for( key )
    # log doesn't have enough precision
    # (Math.log( @key.distance_to(key) ) / Log_2).to_i

    dist = @key.distance_to key
    return nil  if dist.zero?

    idx = -1
    while dist > 0
      idx += 1
      dist >>= 1
    end
    idx
  end

  def bucket_for( key )
    @buckets[ bucket_index_for(key) ]
  end
end

class PeerTable::Bucket
  Size = 20
  attr_reader :peers

  def initialize
    @peers, @queue = [], []
  end

  def empty?
    @peers.empty? && @queue.empty?
  end

  def touch( peer )
    peer.touch
    return  if @peers.include?(peer) || @queue.include?(peer)
    ((@peers.size < Size) ? @peers : @queue).push( peer )
    peer
  end
end

end