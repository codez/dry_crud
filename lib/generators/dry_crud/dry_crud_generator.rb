require 'rails/generators'

class DryCrudGenerator < Rails::Generators::Base

  class_options %w(templates -t) => 'erb'


  def self.source_root
     File.join(File.dirname(__FILE__), 'templates')
  end

  def install_dry_crud
    # copy everything in template subfolders
    exclude = options[:templates].downcase == 'haml' ? '.erb' : '.haml'

    Dir.chdir(self.class.source_root) do
      Dir.glob(File.join('**', '**')).sort.each do |file_source|
        if !File.directory?(file_source) &&
           !file_source.end_with?(exclude) &&
           file_source != 'INSTALL'
          copy_file(file_source)
        end
      end
    end

    readme "INSTALL"
  end

end
