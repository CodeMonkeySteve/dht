require 'dht/node'
require 'dht/peer_server'

module DHT

class HostServer
  PeersName = ::PeerServer::PeersName
  HostName = 'host'.freeze
  HostsName = HostName.pluralize.freeze
  Path = "/#{HostsName}".freeze

  attr_reader :app, :node

  def initialize( app, node )
    @app, @node = app, node
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

  # host index
  def index
    [ 200, {'Content-Type' => 'application/json;charset=utf-8'},
      [ JSON.generate({ HostsName => @node.hosts.to_hash }) + "\n" ] ]
  end

  # FIND_VALUE
  def find( key )
    key = Key.new(key) rescue Key.for_content(key)
    hosts, peers = @node.send( (@request.params['r'] ? :hosts_for! : :hosts_for), key )
    [ 200, {'Content-Type' => 'application/json;charset=utf-8'},
      [ JSON.generate({ :key => key.to_s, HostsName => hosts.map(&:to_hash), PeersName => peers.map(&:to_hash) }) + "\n" ] ]
  end

  # STORE
  def store( key, hosts )
    return  [ 406, {}, 'Not Acceptable']  unless @request.content_type.split(';')[0] == 'application/json'

# FIXME: authentication
#return  [ 403, {}, 'Missing Peer URL' ]  unless @peer

    key = Key.new(key) rescue Key.for_content(key)
    hosts = [hosts]  unless Array === hosts

    num_stored = 0
    for host in hosts
      num_stored += 1  if @node.store( key, host )
    end
    [ 200, {'Content-Type' => 'application/json;charset=utf-8'},
      [ JSON.generate({ :key => key.to_s, :stored => num_stored }) + "\n" ] ]
  end

  module PeerInterface
    # FIND_VALUE
    def hosts_for( key, from_node )
      req = EventMachine::HttpRequest.new("#{url}/#{HostServer::HostsName}/#{key.to_s}").
            get( :head => { 'X-PEER-URL' => from_node.url.to_s, 'Accept' => 'application/json' } )
      hosts, peers = JSON.parse(req.response).values_at( HostServer::HostsName, PeerServer::PeersName )
      hosts.map! { |hash|  Host.new hash['url'] }
      peers.map! { |hash|  Peer.new hash['url'] }
      [ hosts, peers ]
    end

    # STORE
    def store( key, val, from_node )
      res = EventMachine::HttpRequest.new("#{url}/#{HostServer::HostsName}/#{key.to_s}").
            post( :body => JSON.generate([val]), :head => { 'X-PEER-URL' => from_node.url.to_s, 'Accept' => 'application/json' } )
      JSON.parse req.response

# FIXME: error handling

    end
  end

  Peer.send :include, PeerInterface
end

end
