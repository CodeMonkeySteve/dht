require 'bundler'
Bundler.setup
Bundler.require :default, :test, :build

require 'rspec/core/rake_task'

task :default => :spec
Rspec::Core::RakeTask.new :spec

Jeweler::Tasks.new do |g|
  g.name = 'dht'
  g.summary = 'Ruby DHT P2P network'
  g.description = 'Implementation of the Kademlia Distributed Hash Table (DHT) in Ruby'
  g.email = 'steve@finagle.org'
  g.homepage = 'http://github.com/CodeMonkeySteve/dht'
  g.authors = ['Steve Sloan']

#  g.files = %w(
#    README.rdoc MIT-LICENSE
#  ) + FileList['lib/dht/*']
end
Jeweler::GemcutterTasks.new
