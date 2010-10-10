require 'dht/key'
require 'dht/host'
require 'addressable/uri'

module DHT

class Peer < Host
  RefreshPeriod = 10.seconds
  RetryPeriod = 10.seconds

  attr_reader :key

  def ==( that )
    self.key == that.key
  end

  def <=>( that )
    super
  end

  def self.from_hash( hash )
    hash = hash.symbolize_keys
    peer = Peer.new hash[:url]
    #peer.touch hash[:active_at]
  end

  def initialize( url, distance = nil )
    super
    host_with_port = self.url.host
    host_with_port += ":#{self.url.port}"  if self.url.port
    @key = Key.for_content( host_with_port + self.url.path )
    @active_at = @distance = nil
  end

  def to_hash
    super().update :key => @key.to_s
  end

  def refresh( from_node )
    $log.puts "Refresh: #{@url} (#{@key})"
    peers_for from_node.key, from_node
  end

#   peer interface
#   # FIND_NODE
#   def peers_for( key, from_node )
#   end
#
#   # FIND_VALUE
#   def hosts_for( key, from_node )
#   end
#
#   # STORE
#   def store( key, val, from_node )
#   end
end

end