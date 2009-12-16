require 'rubygems'
require 'spork'
require 'rr'
require 'factory_girl'
require 'spec/autorun'

Spork.prefork do
#  Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

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
