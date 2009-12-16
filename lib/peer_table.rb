require 'peer'

module DHT

class PeerTable
  class Bucket
    Size = 20
    attr_reader :peers

    def initialize
      @peers, @queue = [], []
    end

    def empty?
      @peers.empty? && @queue.empty?
    end

    def touch( peer )
      peer.updated_at = Time.now
      return  if @peers.include?(peer) || @queue.include?(peer)
      ((@peers.size < Size) ? @peers : @queue).push( peer )
      peer
    end
  end

  def initialize( id )
    @id = id
    @buckets = (1..(Key::Size * 8)).map { Bucket.new }
  end

  def inspect( ref_key = nil )
    ref_key ||= @id
    return [].inspect  if @buckets.all? { |b|  b.empty? }
    out = StringIO.new
    @buckets.each_with_index do  |bucket, x|
      next  if bucket.peers.empty?
      out.print( '[%03i]' % x )
      for peer in bucket.peers
        out.puts "\t#{peer.url.inspect} #{peer.id.inspect} (d:#{peer.id.distance_to(ref_key)})"
      end
      queue = bucket.instance_variable_get(:@queue)
      out.puts "\t+#{queue.size}"  if queue.any?
    end
    out.string
  end

  def nearest_to( key )
    peers = @buckets.map { |b|  b.peers  }.flatten.sort_by { |peer|  peer.id.distance_to(key)  }[0...Bucket::Size]
#puts '', key.inspect
#peers.each { |peer|  puts "#{peer.url.inspect} [#{peer.id.inspect}] (##{@buckets.index(bucket_for(peer.id))}) d:#{peer.id.distance_to(key)}" }
#peers
  end

  def touch( peer )
    bucket_for( peer.id ).touch( peer )
  end

protected
  Log_2 = Math.log(2)
  def bucket_for( key )
    @buckets[ (Math.log( @id.distance_to(key) ) / Log_2).to_i ]
  end
end

end