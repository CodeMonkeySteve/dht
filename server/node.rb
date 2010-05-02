require 'dht/node'

module DHT

class NodeServer < Sinatra::Base
  def initialize( hostname = 'localhost', port = 3000 )
    url = "http://#{hostname}#{":#{port}" if port != 80}"
    @node = Node.new( Key.for_content(url) )
puts "Node startup: #{@node.key.inspect}"
    super()
  end

  before do
    if peer_url = request.env[:HTTP_X_PEER_URL]
      @peer = Peer.new Key.for_content(peer_url)
      @node.ping_from @peer
    end
  end

  get '/peer/:key'  do
    key = Key.new params[:key]
    peers = @node.peers_for key
    content_type 'application/json', :charset => 'utf-8'
    JSON.generate({ peers: peers })
  end

  get '/value/:key'  do
    key = Key.new params[:key]
    values, peers = @node.values_for key
    content_type 'application/json', :charset => 'utf-8'
    JSON.generate({ values: values, peers: peers })
  end

  post '/value/:key'  do
    key = Key.new params[:key]
    vals = JSON.parse request.body.read

    num_stored = 0
    for val in vals
      num_stored += 1  if @node.store(key, val)
    end
    content_type 'application/json', :charset => 'utf-8'
    JSON.generate({ :stored => num_stored })
  end
end

end