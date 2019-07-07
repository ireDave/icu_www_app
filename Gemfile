source "https://rubygems.org"

gem "rake", "10.4.2"
gem "rails", "4.2.8"
gem "sprockets", "2.12.3" # Latest version of sprockets 2.*. 3.* causes a failure at startup
gem "mysql2"
gem "haml-rails"
gem "sass-rails", "~> 5.0"
gem "uglifier", ">= 1.3.0"
gem "jquery-rails"
gem "cancan", "~> 1.6"
gem "redis"
gem "therubyracer", platforms: :ruby
gem "icu_name", "1.2.5"
gem "icu_utils", "1.3.2"
gem "redcarpet"
gem "stripe"
gem "mailgun-ruby", require: "mailgun"
gem "paperclip", "~> 4.1"
# gem "colorize", "0.7.4" # To avoid capistrano error using ruby 2.4.0 -- https://github.com/Mixd/wp-deploy/issues/130
gem "colored"
gem "whenever", :require => false
gem "quiet_assets"
gem "puma"

group :development do
  gem 'capistrano',         require: false
  gem 'capistrano-rvm',     require: false
  gem 'capistrano-rails',   require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano3-puma',   require: false
  gem 'capistrano-nvm',     require: false
  # Include capistrano-ssh-doctor to check for ssh errors running capistrano
  # gem 'capistrano-ssh-doctor', '~> 1.0'
  gem "wirble"
end

group :development, :test do
  gem "rspec-rails", "~> 3.0"
  gem "capybara"
  gem "selenium-webdriver"
  gem "chromedriver-helper"
  gem "factory_girl_rails", "~> 4.0", require: false
  gem "launchy"
  gem "faker"
  gem "database_cleaner"
  #gem "byebug"
end
