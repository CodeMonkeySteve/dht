require 'dht/node'
require 'em/timers'
require 'ruby-debug'

include DHT

class Poller
  RefreshPeerAfter = 1.minutes
  RefreshValueAfter = 1.day

  attr_accessor :node

  def initialize( node )
    @node = node
  end

  def start
    EM.next_tick { poller }
    self
  end

protected

  def poller
    Fiber.new do
      loop do
        refresh_at, obj = next_obj
        now = Time.now

if refresh_at
  puts '', "=#{now}"
  puts "@#{refresh_at}: #{obj.inspect}"
end

        refresh_at ||= now + 1.second
        if refresh_at <= now
          refresh obj
        else
          fiber = Fiber.current
          EM::Timer.new( refresh_at - now ) do
            fiber.resume
          end
          Fiber.yield
        end
      end
    end.resume
  end

  def refresh( obj )
    case obj
      when Peer
        $log.puts "Refresh: #{obj.url} (#{obj.key})"
        obj.peers_for( node.key, node )

      when ValueCache::Entry
        # FIX ME!
        obj.touch
    end
  end

  def next_obj
    now = Time.now
    objs =
    (@node.values.entries.map { |entry|  [ entry.active_at ? (entry.active_at + RefreshValueAfter) : now, entry ] } +
         @node.peers.to_a.map { |peer|   [ peer.active_at ?  (peer.active_at  + RefreshPeerAfter)  : now, peer ] })
    objs.
      sort.first
  end
end
