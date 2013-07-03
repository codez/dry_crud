# add gem to Gemfile
gem 'dry_crud'

# install gem if missing
out = run 'gem list dry_crud', :capture => true
run 'bundle update dry_crud' if out !~ /dry_crud/

# ask user for options
templates = ask('Which template engine do you use? [ERB|haml]')
tests = ask('Which testing framework do you use? [TESTUNIT|rspec]')
options = ''

if templates.present? && 'haml'.start_with?(templates.downcase)
  gem 'haml'
  options << ' --templates haml'
end

if tests.present? && 'rspec'.start_with?(tests.downcase)
  options << ' --tests rspec'
end

# generate dry_crud with erb or haml
generate 'dry_crud', options

# remove gem from Gemfile
gsub_file 'Gemfile', /gem .dry_crud./, ''

