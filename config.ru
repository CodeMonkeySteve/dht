$LOAD_PATH << File.dirname(__FILE__) << File.dirname(__FILE__)+'/lib'

require 'bundler'
Bundler.setup
Bundler.require

use Rack::Reloader
use Rack::FiberPool

require 'dht/node_server'
run DHT::NodeServer
