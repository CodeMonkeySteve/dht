Gem::Specification.new do |s|
  s.required_rubygems_version = ">= 1.3.6"

  s.name = %q{dht}
  s.version = '0.0.3'
  s.date = %q{2010-03-06}

  s.authors = ['Steve Sloan']
  s.email = ['steve@finagle.org']
  s.homepage = 'http://github.com/CodeMonkeySteve/dht'
  s.summary = "Ruby DHT P2P network"
  s.description = "Implementation of the Kademlia Distributed Hash Table (DHT) in Ruby"

  s.files = Dir.glob('{bin,lib,server}/**/*') + %w(README.rdoc)
  s.bindir = %w(bin)
  s.require_paths = %w(lib)
end

