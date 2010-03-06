begin
  require File.expand_path( '../.bundle/environment', __FILE__ )
rescue LoadError
  require 'rubygems'
  require 'bundler'
  Bundler.setup
  Bundler.require( :default, :test )
end

Spork.prefork do
  require 'spec/autorun'

  # rspec configuration
  Spec::Runner.configure do |config|
    config.mock_with :rr
  end

  # matchers
  Spec::Matchers.define :respond_with do |attributes|
    match do |obj|
      attributes.all?  do |k, v|
        @method = k.to_sym
        @expect, @actual = v, obj.send(@method)
        @expect == @actual
      end
    end
    failure_message_for_should do |obj|
      "expected: #{@expect.inspect},\n" +
      "     got: #{@actual.inspect} (calling #{@method})"
    end
    failure_message_for_should_not do |obj|
      "expected not: #{@expect.inspect} (calling #{@method})"
    end
  end
end

Spork.each_run do
  # clear screen
  print "\x1b[2J\x1b[H" ; $stdout.flush
end
