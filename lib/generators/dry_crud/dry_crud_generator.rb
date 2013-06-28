require 'rails/generators'

class DryCrudGenerator < Rails::Generators::Base

  class_options %w(templates -t) => 'erb'
  class_options %w(tests) => 'testunit'


  def self.source_root
     File.join(File.dirname(__FILE__), 'templates')
  end

  def install_dry_crud
    # copy everything in template subfolders
    exclude_template = options[:templates].downcase == 'haml' ? '.erb' : '.haml'

    exclude_test_dir = case options[:tests].downcase
      when 'rspec' then 'test'
      when 'all' then 'exclude_nothing'
      else 'spec'
    end

    Dir.chdir(self.class.source_root) do
      Dir.glob(File.join('**', '**')).sort.each do |file_source|
        if !File.directory?(file_source) &&
           !file_source.end_with?(exclude_template) &&
           !file_source.start_with?(exclude_test_dir) &&
           file_source != 'INSTALL'
          if file_source.end_with?('.erb')
            copy_file(file_source)
          else
            template(file_source)
          end
        end
      end

      unless exclude_test_dir == 'spec'
        template(File.join('test', 'crud_test_model.rb'),
                  File.join('spec', 'support', 'crud_test_model.rb'))
      end
    end

    readme "INSTALL"
  end

end
