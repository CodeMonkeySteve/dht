source :gemcutter

# Core
gem 'sinatra'
gem 'activesupport', '~> 3.0.0', :require => ['active_support', 'active_support/core_ext']
gem 'haml', '~> 3.0.18', :require => ['haml', 'sass']
gem 'i18n'
gem 'json'
gem 'multimap'

# I/O
gem 'eventmachine', '= 0.12.10'   # must be same as Heroku
gem 'rack-fiber_pool',  :require => 'rack/fiber_pool'
gem 'em-synchrony', :require => [ 'em-synchrony', 'em-synchrony/em-http' ],
#  :git => 'git://github.com/igrigorik/em-synchrony.git'
  :git => 'git://github.com/CodeMonkeySteve/em-synchrony.git'
gem 'em-http-request' #, :git => 'git://github.com/igrigorik/em-http-request.git' #, :require => 'em-http'
gem 'thin'

group :test do
  gem 'autotest'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl', '~> 1.3.1'
  gem 'rspec', '~> 2.0.0.beta'
  gem 'spork'
  gem 'timecop'
end

group :build do
  gem 'jeweler'
#  gem 'rake'
end

group :development do
  gem 'ruby-debug19', :require => 'ruby-debug'
end
