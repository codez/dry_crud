source 'https://rubygems.org'

gem 'rails', '~> 8.0.0'

gem 'puma'

gem 'rake'

gem 'rspec-rails'

gem 'haml'
gem 'jbuilder'

gem 'kaminari'

gem "propshaft"
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
  gem 'sdoc'
  gem 'spring'
end

gem 'simplecov', require: false
gem 'debug', platforms: [:mri, :windows], require: "debug/prelude"

# platform specific gems

platforms :ruby do
  gem 'sqlite3'
end

platforms :jruby do
  gem 'jdbc-sqlite3'
  gem 'activerecord-jdbcsqlite3-adapter'
  gem 'jruby-openssl'
end
