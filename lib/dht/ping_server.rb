require 'dht/node'

module DHT

class PingServer
  attr_reader :app, :node

  def initialize( app, node )
    @app, @node = app, node
  end

  def call( env )
    if peer_url = env['HTTP_X_PEER_URL']
      peer = Peer.new peer_url
      @node.ping_from peer
    end

    resp = @app ? @app.call(env) : [404, {}, []]
    if peer && (resp[0] == 404)
      [ 200, {}, [] ]
    else
      resp
    end
  end
end

end