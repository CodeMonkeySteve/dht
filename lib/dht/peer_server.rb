require 'dht/node'

module DHT

class PeerServer
  PeerName = 'peer'.freeze
  PeersName = PeerName.pluralize.freeze
  Path = "/#{PeersName}".freeze

  attr_reader :app, :node

  def initialize( app, node )
    @app, @node = app, node
    Peer.send :include, PeerInterface
  end

  def call( env )
    @env, @request = env, Rack::Request.new(env)
    if peer_url = @env['HTTP_X_PEER_URL']
      @node.peers.touch Peer.new(peer_url)
    end
    return  @app.call(env)  unless @request.accept.include?('application/json')

    case @request.path_info
      when %r(#{Path}/?$)   then  index
      when %r(#{Path}/(.+)) then  find($1)
      else
        @app ? @app.call(env) : [404, {}, []]
    end
  end

  # peer index
  def index
    [ 200, {'Content-Type' => 'application/json;charset=utf-8'},
      [ JSON.generate(@node.peers.to_hash) + "\n" ] ]
  end

  # FIND_NODE
  def find( key )
    key = Key.new(key) rescue Key.for_content(key)
    peers = @node.peers_for key
    [ 200, {'Content-Type' => 'application/json;charset=utf-8'},
      [ JSON.generate(peers.map(&:to_hash)) + "\n" ] ]
  end

  module PeerInterface
    def peers_for( key, from_node )
      req = EventMachine::HttpRequest.new("#{url}#{PeerServer::Path}/#{key.to_s}").
            get( :head => { 'X-PEER-URL' => from_node.url.to_s, 'Accept' => 'application/json' } )

      if req.response_header.status.zero?
        $log.puts 'Connection Failed'
        @error_at = Time.now
        return []
      end

      from_node.peers.touch self
      peers = JSON.parse( req.response ).map do |hash|
        peer = Peer.from_hash hash
        raise "Peer key mismatch: #{hash['url']} has key #{hash['key']}, expected #{peer.key}"  unless peer.key.to_s == hash['key']
        from_node.peers.add peer
        peer
      end
      peers
    end
  end

  Peer.send :include, PeerInterface
end

end