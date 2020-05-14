source 'https://rubygems.org'

ruby File.read(__dir__ + '/.ruby-version').strip

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2', '>= 5.2.3'
gem 'bundler', '~> 2.0.1'
gem 'puma'
gem 'bootsnap', require: false

gem 'pg'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use debugger
# gem 'debugger', group: [:development, :test]

group :development, :test do
  gem 'rspec'
  gem 'rspec-rails', '>= 3.8.2'
  gem 'factory_bot'
  gem 'factory_bot_rails', '>= 5.0.2'
  gem 'guard'
  gem 'guard-rspec'
  gem 'rb-fsevent'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'pry'
  gem 'pry-rails'
  gem 'tapp'
  gem 'shoulda-matchers'
  gem 'timecop'
  gem 'rubocop'
  gem 'guard-rubocop'
end

group :development do
  gem 'bullet'
end

group :test do
  gem 'webmock', require: 'webmock/rspec'
  gem 'capybara', '>= 3.29.0', require: 'capybara/rspec'
  gem 'launchy'
  gem 'selenium-webdriver'
  gem 'rails-controller-testing', '>= 1.0.4'
end

gem 'devise', '>= 4.7.1'
gem 'kaminari'
gem 'acts-as-taggable-on'
gem 'oj'
gem 'oj_mimic_json'
gem 'feedbag'
gem 'activerecord-import'
gem 'rufus-scheduler', require: false
