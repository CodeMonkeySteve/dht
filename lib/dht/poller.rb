require 'dht/node'
require 'em/timers'
require 'ruby-debug'

include DHT

class Poller
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
          obj.refresh node
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

  def next_obj
    objs = (@node.hosts + @node.peers).map { |obj|  [ obj.next_refresh_at, obj ] }.sort_by(&:first).first
  end
end
