gem 'dry_crud'
run 'bundle update dry_crud'

if yes?("Use HAML instead of ERB?")
  generate 'dry_crud', '-t HAML'
else
  generate 'dry_crud'
end

gsub_file 'Gemfile', /gem .dry_crud./, ""

