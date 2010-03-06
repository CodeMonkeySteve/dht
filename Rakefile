begin
  require File.expand_path( '.bundle/environment', __FILE__ )
rescue LoadError
  require 'rubygems'
  require 'bundler'
  Bundler.setup
  Bundler.require( :default, :build )
end
require 'rake/testtask'
require 'rake/rdoctask'
require 'spec/rake/spectask'

task :default => :spec

desc "Run all specs in spec directory (excluding plugin specs)"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

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
