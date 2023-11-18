# encoding: UTF-8
#!/usr/bin/env rake

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end
require 'rake/testtask'
require 'rspec/core/rake_task'
require 'sdoc'
require 'rdoc/task'

TEST_APP_ROOT  = File.join(File.dirname(__FILE__),
                           'test', 'test_app')
GENERATOR_ROOT = File.join(File.dirname(__FILE__),
                           'lib', 'generators', 'dry_crud')

task default: :test

desc "Run all tests"
task test: ['test:unit', 'test:spec']

namespace :test do

  desc "Run Test::Unit tests"
  Rake::TestTask.new(unit: 'test:app:init') do |test|
    test.libs << "test/test_app/test"
    test.test_files = FileList["test/test_app/test/**/*_test.rb"]
    test.verbose = true
  end

  desc "Run RSpec tests"
  RSpec::Core::RakeTask.new(spec: 'test:app:init') do |t|
    t.ruby_opts = "-I test/test_app/spec"
    t.pattern = "test/test_app/spec/**/*_spec.rb"
  end

  namespace :app do

    desc "Initializes the test application with a couple of classes"
    task init: [:seed, :customize]

    desc "Customize some of the functionality provided by dry_crud"
    task customize: ['test:app:add_pagination',
                     'test:app:use_bootstrap',
                     'test:app:build_assets'
                     ]

    desc "Create a rails test application"
    task :create do
      unless File.exist?(TEST_APP_ROOT)
        sh "rails new #{TEST_APP_ROOT} --css=bootstrap"
        file_replace(File.join(TEST_APP_ROOT, 'Gemfile'),
                     /\z/,
                     File.read(File.join(File.dirname(__FILE__),
                               'test', 'templates', 'Gemfile.append')))
        sh "cd #{TEST_APP_ROOT}; bundle install --local" # update Gemfile.lock

        sh "cd #{TEST_APP_ROOT}; rails g rspec:install"
        FileUtils.rm_f(File.join(TEST_APP_ROOT,
                                 'test', 'performance', 'browsing_test.rb'))
        file_replace(File.join(TEST_APP_ROOT, 'test', 'test_helper.rb'),
                     /\A/,
                     "require 'simplecov'\nSimpleCov.start do\n" +
                     "  coverage_dir 'coverage/test'\nend\n")
        file_replace(File.join(TEST_APP_ROOT, 'spec', 'spec_helper.rb'),
                     /\A/,
                     "require 'simplecov'\nSimpleCov.start do\n" +
                     "  coverage_dir 'coverage/spec'\nend\n")
        file_replace(File.join(TEST_APP_ROOT, 'spec', 'rails_helper.rb'),
          "# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }",
          "Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }")
      end
    end

    desc "Run the dry_crud generator for the test application"
    task generate_crud: [:create, :environment] do
      require File.join(GENERATOR_ROOT, 'dry_crud_generator_base')
      require File.join(GENERATOR_ROOT, 'dry_crud_generator')

      DryCrudGenerator.new([],
                           { force: true,
                             templates: %w[1 yes true].include?(ENV['HAML']) ? 'haml' : 'erb',
                             tests: 'all' },
                           destination_root: TEST_APP_ROOT).invoke_all
    end

    task :environment do
      ENV['RAILS_ROOT'] = TEST_APP_ROOT
      ENV['RAILS_ENV'] = 'test'

      require(File.join(TEST_APP_ROOT, 'config', 'environment'))
    end

    desc "Populates the test application with some models and controllers"
    task populate: [:generate_crud] do
      # copy test app templates
      FileUtils.cp_r(File.join(File.dirname(__FILE__),
                               'test', 'templates', '.'),
                     TEST_APP_ROOT)

      # copy shared fixtures
      FileUtils.cp_r(File.join(File.dirname(__FILE__),
                               'test', 'templates', 'test', 'fixtures'),
                     File.join(TEST_APP_ROOT, 'spec'))

      # remove unused template type, erb or haml
      exclude = %w[1 yes true].include?(ENV['HAML']) ? 'erb' : 'haml'
      Dir.glob(File.join(TEST_APP_ROOT,
                         'app', 'views', '**', "*.#{exclude}")).each do |f|
        FileUtils.rm(f)
      end
    end

    desc "Insert seed data into the test database"
    task seed: :populate do
      # migrate the database
      FileUtils.cd(TEST_APP_ROOT) do
        sh "rake db:migrate db:seed RAILS_ENV=development --trace"
        # db:test:prepare does not work for jdbcsqlite3
        sh "rake db:migrate RAILS_ENV=test --trace"
      end
    end

    desc "Adds pagination to the test app"
    task :add_pagination do
      list_ctrl = File.join(TEST_APP_ROOT,
                            'app', 'controllers', 'list_controller.rb')
      file_replace(list_ctrl,
                   /def list_entries\n\s+(.+)\s*\n/,
                   "def list_entries\n" +
                   "    list = \\1\n" +
                   "    list.page(params[:page]).per(10)\n")
      file_replace(File.join(TEST_APP_ROOT,
                             'app', 'views', 'list', 'index.html.erb'),
                   "<%= render 'list' %>",
                   "<%= paginate entries %>\n\n<%= render 'list' %>")
      file_replace(File.join(TEST_APP_ROOT,
                             'app', 'views', 'list', 'index.html.haml'),
                   "= render 'list'",
                   "= paginate entries\n\n= render 'list'")
    end

    desc "Use Boostrap Icons in the test app"
    task :use_bootstrap do
      sh "cd #{TEST_APP_ROOT}; yarn add bootstrap-icons"

      app_css = File.join(TEST_APP_ROOT, 'app', 'assets', 'stylesheets', 'application.bootstrap.scss')
      if File.exist?(app_css) && File.read(app_css) !~ /bootstrap-icons/
        file_replace(app_css,
                      /\n\z/,
                      "\n@import 'bootstrap-icons/font/bootstrap-icons';\n@import 'crud';\n")
      end

      assets = File.join(TEST_APP_ROOT, 'config', 'initializers', 'assets.rb')
      if File.exist?(assets) && File.read(assets) !~ /bootstrap-icons/
        file_replace(assets,
                      /\n\z/,
                      "\nRails.application.config.assets.paths << Rails.root.join('node_modules/bootstrap-icons/font')\n")
      end

      FileUtils.rm_f(File.join(TEST_APP_ROOT,
                               'app', 'assets', 'stylesheets', 'sample.scss'))
    end

    desc "Build javascript and css in the test app"
    task :build_assets do
      sh "cd #{TEST_APP_ROOT}; rails javascript:build css:build"
    end
  end
end

desc "Clean up all generated resources"
task :clobber do
  FileUtils.rm_rf(TEST_APP_ROOT)
  FileUtils.rm_rf('pkg')
end

Bundler::GemHelper.install_tasks

# :rdoc task
Rake::RDocTask.new do |rdoc|
  rdoc.title  = 'dry_crud'
  rdoc.options << '--all' << '--line-numbers' << '--fmt' << 'sdoc'
  rdoc.rdoc_files.include(
    *FileList.new('*') do |list|
       list.exclude(/(^|[^.a-z])[a-z]+/)
       list.exclude('TODO')
     end.to_a)
  rdoc.rdoc_files.include('app/**/*.rb')
  rdoc.rdoc_files.include('lib/generators/dry_crud/templates/**/*.rb')
  rdoc.rdoc_files.exclude('lib/generators/dry_crud/templates/**/*_test.rb')
  rdoc.rdoc_files.exclude('lib/generators/dry_crud/templates/**/*_spec.rb')
  rdoc.rdoc_files.exclude('lib/generators/dry_crud/templates/**/*_examples.rb')
  rdoc.rdoc_files.exclude('TODO')

  rdoc.rdoc_dir = 'rdoc'
  rdoc.main = 'README.rdoc'
end

desc "Deploy rdoc to website"
task site: :rdoc do
  if ENV['DEST']
    sh "rsync -rzv rdoc/ #{ENV['DEST']}"
  else
    puts "Please specify a destination with DEST=user@server:/deploy/dir"
  end
end


def file_replace(file, expression, replacement)
  return unless File.exist?(file)
  text = File.read(file)
  replaced = text.gsub(expression, replacement)
  if text == replaced
    puts "WARN: Nothing replaced in '#{file}' for '#{expression}'"
  end
  File.open(file, 'w') { |f| f.puts replaced }
end
