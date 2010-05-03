require 'dht/node'
require 'dht/block_cache'
require 'fileutils'

module DHT

class NodeServer < Sinatra::Base
  def initialize( hostname = 'localhost', port = 3000 )
    url = "http://#{hostname}#{":#{port}" if port != 80}"
    @node = Node.new( Key.for_content(url) )

    block_dir = File.dirname(__FILE__)+'../cache'
    FileUtils.mkdir_p block_dir
    @blocks = BlockCache.new @node.key, block_dir

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
    JSON.generate({ peers: peers }) + "\n"
  end

  get '/block/:key'  do
    key = Key.new params[:key]


    hosts, peers = @node.hosts_for key
    if request.content_type == 'application/json'
      content_type 'application/json', :charset => 'utf-8'
      JSON.generate({ hosts: hosts, peers: peers }) + "\n"
    else
    end
  end

  post '/block/:key'  do
    key = Key.new params[:key]
p request.content_type
    if request.content_type == 'application/json'
      vals = JSON.parse request.body.read
      num_stored = 0
      for val in vals
        num_stored += 1  if @node.store(key, val)
      end
      content_type 'application/json', :charset => 'utf-8'
      JSON.generate({ :stored => num_stored }) + "\n"
    end
  end
end

end
