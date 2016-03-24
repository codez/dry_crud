# encoding: UTF-8

require 'rails/generators'

class DryCrudGeneratorBase < Rails::Generators::Base
  def self.template_root
    File.join(File.dirname(__FILE__), 'templates')
  end

  def self.gem_root
    File.join(File.dirname(__FILE__), '..', '..', '..')
  end

  def self.source_paths
    [gem_root,
     template_root]
  end

  private

  def all_template_files
    { self.class.gem_root      => template_files(self.class.gem_root, 'app', 'config'),
      self.class.template_root => template_files(self.class.template_root) }
  end

  def template_files(root, *folders)
    pattern = File.join('**', '**')
    pattern = File.join("{#{folders.join(',')}}", pattern) if folders.present?
    Dir.chdir(root) do
      Dir.glob(pattern).sort.reject { |f| File.directory?(f) }
    end
  end

  def copy_files(root_files)
    root_files.each do |root, files|
      Dir.chdir(root) do
        files.each do |file_source|
          copy_file_source(file_source) if should_copy?(file_source)
        end
      end
    end
  end

  def should_copy?(_file_source)
    true
  end

  def copy_file_source(file_source)
    if file_source.end_with?('.erb')
      copy_file(file_source)
    else
      template(file_source)
    end
  end
end
