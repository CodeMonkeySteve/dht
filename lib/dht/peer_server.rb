require 'dht/node'

module DHT

class PeerServer
  attr_reader :app, :node, :opts

  def initialize( app, node, opts = {} )
    @app, @node = app, node
    @opts = {
      :prefix => '/peers',
    }.update opts
  end

  def call( env )
    @env, @request = env, Rack::Request.new(env)
    return  @app.call(env)  unless @request.accept.include?('application/json')

    prefix = @opts[:prefix]
    case @request.path_info
      when %r(#{prefix}/?$)   then  index
      when %r(#{prefix}/(.+)) then  find($1)
      else
        @app ? @app.call(env) : [404, {}, []]
    end
  end

  # peer index
  def index
    [ 200, {'Content-Type' => 'application/json;charset=utf-8'},
      [ JSON.generate(@node.peers.to_hash), "\n" ] ]
  end

  # FIND_NODE
  def find( key )
    key = Key.new(key) rescue Key.for_content(key)
    peers = @node.peers_for key
    [ 200, {'Content-Type' => 'application/json;charset=utf-8'},
      [ JSON.generate(peers.map(&:to_hash)), "\n" ] ]
  end
end

end