source 'https://rubygems.org'

gem 'rails', '~> 7.1.0'

gem 'puma'

gem 'rake'
gem 'sdoc'
gem 'rspec-rails'

gem 'haml'
gem 'jbuilder'

gem 'kaminari'

gem "sprockets-rails"
gem "jsbundling-rails"
gem "cssbundling-rails"
gem "turbo-rails"
gem "stimulus-rails"

gem 'bootsnap', require: false

gem 'tzinfo-data', platforms: [:windows, :jruby]

group :development do
  gem 'web-console'
  gem 'rubocop'
  gem 'rubocop-rails'
  gem 'spring'
end

gem 'simplecov', require: false
gem 'debug', platforms: [:mri, :windows]

# platform specific gems

platforms :ruby do
  gem 'sqlite3'
end

platforms :jruby do
  gem 'jdbc-sqlite3'
  gem 'activerecord-jdbcsqlite3-adapter'
  gem 'jruby-openssl'
end
