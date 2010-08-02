require 'rails/generators'

class DryCrudGenerator < Rails::Generators::Base
  
  def self.source_root
     File.join(File.dirname(__FILE__), 'templates')
  end
  
  def install_dry_crud
    # copy everything in template subfolders
    Dir.chdir(self.class.source_root) do
      Dir.glob("*").each do |f|
        directory(f) if File.directory?(f)
      end
    end
    
    readme "INSTALL"
  end

end
