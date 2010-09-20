require 'dht/node'

module DHT

class ValueServer
  attr_reader :app, :node, :opts

  def initialize( app, node, opts = {} )
    @app, @node = app, node
    @opts = {
      :prefix => '/values',
    }.update opts
  end

  def call( env )
    @env, @request = env, Rack::Request.new(env)
    return  @app.call(env)  unless @request.accept.include?('application/json')

    prefix = @opts[:prefix]
    case @request.path_info
      when %r(#{prefix}/?$)
        index
      when %r(#{prefix}/(.+)$)
        if @request.get?
          find( $1 )
        elsif @request.post?
          store( $1, @request.body.read )
        else
          [ 404, {}, [] ]
        end
      else
        @app ? @app.call(env) : [404, {}, []]
    end
  end

  # value index
  def index
    [ 200, {'Content-Type' => 'application/json;charset=utf-8'},
      [ JSON.generate(@node.values.to_a), "\n" ] ]
  end

  # FIND_VALUE
  def find( key )
    key = Key.new(key) rescue Key.for_content(params[:key])
    values, peers = @node.values_for key
    [ 200, {'Content-Type' => 'application/json;charset=utf-8'},
      [ JSON.generate({ ValueCache::TypeName.pluralize => values, :peers => peers.map(&:to_hash) }), "\n" ] ]
  end

  # STORE
  def store( key, values )
    return  [ 406, {}, 'Not Acceptable']  unless @request.content_type == 'application/json'
    #return  [ 403, {}, 'Missing Peer URL' ]  unless @peer

    key = Key.new(key) rescue Key.for_content(params[:key])
    values = JSON.parse values
    values = [values]  unless Array === values

    num_stored = 0
    for value in values
      num_stored += 1  if @node.store( key, value )
    end
    [ 200, {'Content-Type' => 'application/json;charset=utf-8'},
      [ JSON.generate({ :stored => num_stored }), "\n" ] ]
  end
end

end