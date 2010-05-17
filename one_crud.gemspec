require 'rubygems' 
require 'rake'

ONE_CRUD_GEMSPEC = Gem::Specification.new do |spec| 
	spec.name = 'one_crud' 
	spec.summary = "Generates a generic and extendable controller with create, read, update and delete (CRUD) actions for Rails."
	spec.version = File.read('VERSION').strip
	spec.author = 'Pascal Zumkehr'
	spec.email = 'spam@codez.ch' 
	spec.description = <<-END
Generates a generic and extendable controller with create, read, update and delete (CRUD) actions for Rails.
END

  spec.require_path = 'rails_generators'

	# We need the revision file to exist, 
	# so we just create it if it doesn't. 
	# It'll usually just get overwritten, though. 
	File.open('REVISION', 'w') { |f| f.puts "(unknown)" } unless File.exist?('REVISION') 

	readmes = FileList.new('*') do |list|
		list.exclude(/(^|[^.a-z])[a-z]+/) 
		list.exclude('TODO') 
		list.include('REVISION')
	end.to_a 
	spec.files = FileList['rails_generators/**/*', 'test/templates/**/*', 'Rakefile'].to_a + readmes 
	#spec.homepage = 'http://haml.hamptoncatlin.com/'
	spec.has_rdoc = true 
	spec.extra_rdoc_files = readmes 
	spec.rdoc_options += [
'--title', 'One Crud', '--main', 'README.rdoc', '--line-numbers', '--inline-source'
] 
end