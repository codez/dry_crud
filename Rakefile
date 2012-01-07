require 'rubygems'
require 'rake/testtask'
require 'rubygems/package_task' 
require 'rdoc/task' 

load 'dry_crud.gemspec'

TEST_APP_ROOT  = File.join(File.dirname(__FILE__), 'test', 'test_app')
GENERATOR_ROOT = File.join(File.dirname(__FILE__), 'lib', 'generators', 'dry_crud')

task :default => :test

desc "Run all tests"
task :test => ['test:app:init'] do
  Rake::TestTask.new do |test| 
    test.libs << "test/test_app/test" 
    test.test_files = Dir[ "test/test_app/test/**/*_test.rb" ] 
    test.verbose = true
  end
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test| 
    test.libs << "test/test_app/test"
    test.test_files = Dir[ "test/test_app/test/**/*_test.rb" ]
    test.rcov_opts = ['--text-report',
                      '-i', '"test\/test_app\/app\/.*"',
                      '-x', '"\/Library\/Ruby\/.*"']
    test.verbose = true
end

namespace :test do
  namespace :app do
    task :environment do
      ENV['RAILS_ROOT'] = TEST_APP_ROOT
      ENV['RAILS_ENV'] = 'test'
      
      require(File.join(TEST_APP_ROOT, 'config', 'environment'))
    end
  
    desc "Create a rails test application"
    task :create do
      unless File.exist?(TEST_APP_ROOT)
        sh "rails new #{TEST_APP_ROOT}"
        FileUtils.cp(File.join(File.dirname(__FILE__), 'test', 'templates', 'Gemfile'), TEST_APP_ROOT)
        sh "cd #{TEST_APP_ROOT}; bundle install" # update Gemfile.lock
        FileUtils.rm_f(File.join(TEST_APP_ROOT, 'test', 'performance', 'browsing_test.rb'))
      end
    end
      
    desc "Run the dry_crud generator for the test application"
    task :generate_crud => [:create, :environment] do
      require File.join(GENERATOR_ROOT, 'dry_crud_generator')
    
      DryCrudGenerator.new('', {:force => true, :templates => ENV['HAML'] ? 'haml' : 'erb'}, :destination_root => TEST_APP_ROOT).invoke_all
    end
   
    desc "Initializes the test application with a couple of classes"
    task :init => :generate_crud do
      FileUtils.cp_r(File.join(File.dirname(__FILE__), 'test', 'templates', '.'), TEST_APP_ROOT)
      FileUtils.rm_f(File.join(TEST_APP_ROOT, 'public', 'index.html'))
      layouts = File.join(TEST_APP_ROOT, 'app', 'views', 'layouts')
      FileUtils.mv(File.join(layouts, 'crud.html.erb'),
                   File.join(layouts, 'application.html.erb'), 
                   :force => true) if File.exists?(File.join(layouts, 'crud.html.erb'))
      FileUtils.mv(File.join(layouts, 'crud.html.haml'),
                   File.join(layouts, 'application.html.haml'), 
                   :force => true) if File.exists?(File.join(layouts, 'crud.html.haml'))
      exclude = ENV['HAML'] ? 'erb' : 'haml'
      Dir.glob(File.join(TEST_APP_ROOT, 'app', 'views', '**', "*.#{exclude}")).each do |f|
        FileUtils.rm(f)
      end
      FileUtils.cd(TEST_APP_ROOT) do
        sh "rake db:migrate db:seed RAILS_ENV=development --trace"
        sh "rake db:migrate RAILS_ENV=test --trace"  # db:test:prepare does not work for jdbcsqlite3
      end
    end
  end
end

desc "Clean up all generated resources"
task :clobber do
  FileUtils.rm_rf(TEST_APP_ROOT)
end

desc "Install dry_crud as a local gem." 
task :install => [:package] do
  sudo = RUBY_PLATFORM =~ /win32/ ? '' : 'sudo' 
  gem = RUBY_PLATFORM =~ /java/ ? 'jgem' : 'gem' 
  sh %{#{sudo} #{gem} install --no-ri pkg/dry_crud-#{File.read('VERSION').strip}.gem}
end

desc "Deploy rdoc to website"
task :site => :rdoc do
  if ENV['DEST']
    sh "rsync -rzv rdoc/ #{ENV['DEST']}"
  else
    puts "Please specify a destination with DEST=user@server:/deploy/dir"
  end
end

# :package task
Gem::PackageTask.new(DRY_CRUD_GEMSPEC) do |pkg|
  if Rake.application.top_level_tasks.include?('release')
    pkg.need_tar_gz = true 
    pkg.need_tar_bz2 = true 
    pkg.need_zip  = true
  end 
end

# :rdoc task
Rake::RDocTask.new do |rdoc| 
  rdoc.title  = 'Dry Crud' 
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include(*FileList.new('*') do |list|
    list.exclude(/(^|[^.a-z])[a-z]+/)
    list.exclude('TODO') 
    end.to_a)
  rdoc.rdoc_files.include('lib/generators/dry_crud/templates/**/*.rb') 
  rdoc.rdoc_files.exclude('lib/generators/dry_crud/templates/**/*_test.rb') 
  rdoc.rdoc_files.exclude('TODO') 
    
  rdoc.rdoc_dir = 'rdoc'
  rdoc.main = 'README.rdoc' 
end

desc "Outputs the commands required for a release. Does not perform any other actions"
task :release do
  version = File.read('VERSION').strip
  puts "Issue the following commands to perform a release:"
  puts " $ git tag version-#{version} -m \"Version tag for dry_crud-#{version}.gem\""
  puts " $ git push --tags"
  puts " $ rake repackage"
  puts " $ gem push pkg/dry_crud-#{version}.gem"
end
