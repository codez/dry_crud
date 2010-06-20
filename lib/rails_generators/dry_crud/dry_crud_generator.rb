require 'rails/generators'

class DryCrudGenerator < Rails::Generators::Base
	
  def self.source_root
     File.join(File.dirname(__FILE__), 'templates')
  end
  
	def install_dry_crud
    p destination_root 
		# copy everything in template subfolders
		Dir.chdir(self.class.source_root) do
			Dir.glob("*/**/*").each do |f|
				if File.directory?(f)
					directory f
				else
					copy_file f, f
				end
			end
		end
		
		readme "INSTALL"
  end
  


end