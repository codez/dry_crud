# encoding: UTF-8

def use_gem(name, options = {})
  gem name, options
  @used_gems ||= []
  @used_gems << name
end

# ask user for options
templates = ask('Which template engine do you use? [ERB|haml]')
tests = ask('Which testing framework do you use? [TESTUNIT|rspec]')
options = ''

if templates.present? && 'haml'.start_with?(templates.downcase)
  use_gem 'haml'
  options << ' --templates haml'
end

if tests.present? && 'rspec'.start_with?(tests.downcase)
  use_gem 'rspec-rails', group: %i[development test]
  options << ' --tests rspec'
end

use_gem 'dry_crud'

# install missing gems
installed = run('gem list', capture: true)
news = @used_gems.any? do |g|
  installed !~ /#{g}/
end
run 'bundle install' if news

# setup rspec
if tests.present? && 'rspec'.start_with?(tests.downcase)
  generate 'rspec:install'
end

# generate dry_crud with erb or haml
generate 'dry_crud', options

# remove gem from Gemfile
gsub_file 'Gemfile', /gem .dry_crud./, ''
