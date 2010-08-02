require 'rubygems'
require "rake/testtask"
require 'rake/gempackagetask' 
require 'rake/rdoctask' 
sdoc = begin 
  require 'sdoc'
  true
rescue Exception
  false
end

load 'dry_crud.gemspec'

TEST_APP_ROOT  = File.join(File.dirname(__FILE__), 'test', 'test_app')
GENERATOR_ROOT = File.join(File.dirname(__FILE__), 'lib', 'rails_generators', 'dry_crud')

task :default => :test

desc "Run all tests"
task :test => ['test:app:init'] do
  Rake::TestTask.new do |test| 
    test.libs << "test/test_app/test" 
    test.test_files = Dir[ "test/test_app/test/**/*_test.rb" ] 
    test.verbose = true
  end
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
      end
    end
      
    desc "Run the dry_crud generator for the test application"
    task :generate_crud => [:create, :environment] do
      require File.join(GENERATOR_ROOT, 'dry_crud_generator')
    
      DryCrudGenerator.new('', {:force => true}, :destination_root => TEST_APP_ROOT).invoke_all
    end
   
    desc "Initializes the test application with a couple of classes"
    task :init => :generate_crud do
      FileUtils.cp_r(File.join(File.dirname(__FILE__), 'test', 'templates', '.'), TEST_APP_ROOT)
      FileUtils.cd(TEST_APP_ROOT) do
        sh "rake db:migrate db:test:prepare"
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
  sh %{#{sudo} #{gem} install --no-ri pkg/dry_crud-#{File.read('VERSION').strip}}
end

desc "Deploy rdoc to website"
task :site => :rdoc do
  sh "rsync -rzv rdoc/ #{ENV['DEST']}"
end

# :package task
Rake::GemPackageTask.new(DRY_CRUD_GEMSPEC) do |pkg|
  if Rake.application.top_level_tasks.include?('release')
    pkg.need_tar_gz = true 
    pkg.need_tar_bz2 = true 
    pkg.need_zip  = true
  end 
end

# :rdoc task
Rake::RDocTask.new do |rdoc| 
  rdoc.title  = 'Dry Crud' 
  rdoc.options << '--line-numbers' << '--inline-source'
  if sdoc
    rdoc.options << '--fmt' << 'shtml'
    rdoc.template = 'direct'
  end
  rdoc.rdoc_files.include(*FileList.new('*') do |list|
    list.exclude(/(^|[^.a-z])[a-z]+/)
    list.exclude('TODO') 
    end.to_a)
  rdoc.rdoc_files.include('rails_generators/dry_crud/templates/**/*.rb') 
  rdoc.rdoc_files.exclude('rails_generators/dry_crud/templates/**/*_test.rb') 
  rdoc.rdoc_files.exclude('TODO') 
    
  rdoc.rdoc_dir = 'rdoc'
  rdoc.main = 'README.rdoc' 
end
