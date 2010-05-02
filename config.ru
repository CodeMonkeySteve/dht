$LOAD_PATH << File.dirname(__FILE__) << File.dirname(__FILE__)+'/lib'

begin
  # Require the preresolved locked set of gems.
  require ::File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  # Fallback on doing the resolve at runtime.
  require 'rubygems'
  require 'bundler'
  Bundler.setup
  Bundler.require
end

require 'ruby-debug'
use Rack::Reloader

require 'server/node'
run DHT::NodeServer
