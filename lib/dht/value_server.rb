require 'dht/node'
require 'dht/peer_server'

module DHT

class ValueServer
  PeersName = ::PeerServer::PeersName
  ValueName = 'value'.freeze
  ValuesName = ValueName.pluralize.freeze
  Path = "/#{ValuesName}".freeze

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
      when %r(#{Path}/?$)
        index
      when %r(#{Path}/(.+)$)
        if @request.get?
          find( $1 )
        elsif @request.post?
          store( $1, JSON.parse(@request.body.read) )
        else
          [404, {}, []]
        end
      else
        @app ? @app.call(env) : [404, {}, []]
    end
  end

  # value index
  def index
    [ 200, {'Content-Type' => 'application/json;charset=utf-8'},
      [ JSON.generate({ ValuesName => @node.values.to_a }) + "\n" ] ]
  end

  # FIND_VALUE
  def find( key )
    key = Key.new(key) rescue Key.for_content(key)
    values, peers = @node.send( (@request.params['r'] ? :values_for! : :values_for), key )
    [ 200, {'Content-Type' => 'application/json;charset=utf-8'},
      [ JSON.generate({ :key => key.to_s, ValuesName => values, PeersName => peers.map(&:to_hash) }) + "\n" ] ]
  end

  # STORE
  def store( key, values )
    return  [ 406, {}, 'Not Acceptable']  unless @request.content_type.split(';')[0] == 'application/json'

# FIXME: authentication
#return  [ 403, {}, 'Missing Peer URL' ]  unless @peer

    key = Key.new(key) rescue Key.for_content(key)
    values = [values]  unless Array === values

    num_stored = 0
    for value in values
      num_stored += 1  if @node.store( key, value )
    end
    [ 200, {'Content-Type' => 'application/json;charset=utf-8'},
      [ JSON.generate({ :key => key.to_s, :stored => num_stored }) + "\n" ] ]
  end

  module PeerInterface
    # FIND_VALUE
    def values_for( key, from_node )
      req = EventMachine::HttpRequest.new("#{url}/#{ValuesName}/#{key.to_s}").
            get( :head => { 'X-PEER-URL' => from_node.url.to_s, 'Accept' => 'application/json' } )
      values, peers = JSON.parse(req.response).values_at(ValuesName, PeerServer::PeersName)
      peers.map! { |hash|  Peer.new hash['url'], hash['active_at'] }
      [ values, peers ]
    end

    # STORE
    def store( key, val, from_node )
      res = EventMachine::HttpRequest.new("#{url}/#{ValuesName}/#{key.to_s}").
            post( :body => JSON.generate([val]), :head => { 'X-PEER-URL' => from_node.url.to_s, 'Accept' => 'application/json' } )
      JSON.parse req.response

# FIXME: error handling

    end
  end
end


end