# encoding: UTF-8

require 'rails/generators'

# Copies all dry_crud files to the rails application.
class DryCrudGenerator < Rails::Generators::Base

  class_options %w(templates -t) => 'erb'
  class_options %w(tests) => 'testunit'

  def self.template_root
     File.join(File.dirname(__FILE__), 'templates')
  end

  def self.gem_root
     File.join(File.dirname(__FILE__), '..', '..', '..')
  end

  def self.source_paths
    [self.gem_root,
     self.template_root]
  end

  # copy everything to application
  def install_dry_crud
    copy_files(self.class.gem_root, 'app', 'config')
    copy_files(self.class.template_root)

    Dir.chdir(self.class.template_root) do
      copy_crud_test_model
    end

    readme 'INSTALL'
  end

  private

  def copy_files(root, *folders)
    Dir.chdir(root) do
      files = if folders.present? 
        File.join("{#{folders.join(',')}}", '**', '**') 
      else
        File.join('**', '**')
      end
      Dir.glob(files).sort.each do |file_source|
        puts file_source
        copy_file_source(file_source) if should_copy?(file_source)
      end
    end
  end

  def should_copy?(file_source)
    !File.directory?(file_source) &&
    !file_source.end_with?(exclude_template) &&
    !file_source.start_with?(exclude_test_dir) &&
    file_source != 'INSTALL'
  end

  def copy_file_source(file_source)
    if file_source.end_with?('.erb')
      copy_file(file_source)
    else
      template(file_source)
    end
  end

  def copy_crud_test_model
    unless exclude_test_dir == 'spec'
      template(File.join('test', 'support', 'crud_test_model.rb'),
               File.join('spec', 'support', 'crud_test_model.rb'))
    end
  end

  def exclude_template
    options[:templates].downcase == 'haml' ? '.erb' : '.haml'
  end

  def exclude_test_dir
    case options[:tests].downcase
    when 'rspec' then 'test'
    when 'all' then 'exclude_nothing'
    else 'spec'
    end
  end
end
