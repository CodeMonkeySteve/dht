source :gemcutter

# Core
gem 'sinatra'
gem 'activesupport', '~> 6.0.3', :require => ['active_support', 'active_support/core_ext']
gem 'haml', '~> 5.1.2', :require => ['haml', 'sass']
gem 'i18n'
gem 'json'
gem 'multimap'

# I/O
gem 'eventmachine', '= 0.12.10'   # must be same as Heroku
gem 'rack-fiber_pool',  :require => 'rack/fiber_pool'
gem 'em-synchrony', :require => [ 'em-synchrony', 'em-synchrony/em-http' ], :git => 'git://github.com/igrigorik/em-synchrony.git'
gem 'em-http-request' #, :git => 'git://github.com/igrigorik/em-http-request.git' #, :require => 'em-http'
gem 'thin'

if (ENV['RACK_ENV'] == 'production') || (ENV['USER'] =~ /^repo\d+$/)  # kludge for Heroku
  group :production do
    gem 'hassle', :git => 'git://github.com/Papipo/hassle.git'
  end
else
  group :test do
    gem 'autotest'
    gem 'capybara'
    gem 'database_cleaner'
    gem 'factory_girl', '~> 1.3.1'
    gem 'rspec', '~> 2.0.0.rc'
    gem 'spork'
    gem 'timecop'
  end
  group :development do
    gem 'ruby-debug19', :require => 'ruby-debug'
  end
end
