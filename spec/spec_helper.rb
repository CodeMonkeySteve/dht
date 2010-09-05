ENV['RAILS_ENV'] ||= 'test'
Bundler.require(:default, :test) if defined?(Bundler)
require 'spork'

Spork.prefork do
  Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

  # rspec configuration
  Rspec.configure do |config|
    config.mock_with :rspec
  end
end

Spork.each_run do
  # clear screen
  print "\x1b[2J\x1b[H" ; $stdout.flush
end
