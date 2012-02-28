# add gem to Gemfile
gem 'dry_crud'

# install gem if missing
out = run "gem list dry_crud", :capture => true
run 'bundle update dry_crud' if out !~ /dry_crud/

# generate dry_crud with erb or haml
templates = ask("Which template engine do you use? [ERB|haml]")
if "haml".start_with?(templates.downcase)
  gem 'haml'
  generate 'dry_crud', '-t haml'
else
  generate 'dry_crud'
end

# remove gem from Gemfile
gsub_file 'Gemfile', /gem .dry_crud./, ""

