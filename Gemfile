source 'https://rubygems.org'

gem 'rails', '~> 6.0.0'

gem 'puma'

gem 'rake'
gem 'sdoc'
gem 'rspec-rails'

gem 'haml'
gem 'jbuilder'

gem 'webpacker', '~> 4.0'

gem 'kaminari'

gem 'sass-rails'
gem 'turbolinks'

gem 'bootsnap', '>= 1.4.2', require: false

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :development do
  gem 'web-console'
  gem 'listen'
  gem 'spring'
  gem 'spring-watcher-listen'
end

gem 'simplecov', require: false
gem 'byebug', platforms: [:mri]

# platform specific gems

platforms :ruby do
  gem 'sqlite3'
  gem 'mini_racer'
end

platforms :jruby do
  gem 'jdbc-sqlite3'
  gem 'activerecord-jdbcsqlite3-adapter'
  gem 'jruby-openssl'
end
