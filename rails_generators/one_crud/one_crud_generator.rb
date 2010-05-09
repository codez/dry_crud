class OneCrudGenerator < Rails::Generator::Base
	
	def manifest
		record do |m|
			# copy everything in template subfolders
			Dir.chdir(File.join(File.dirname(__FILE__), 'templates')) do
				Dir.glob("*/**/*").each do |f|
					if File.directory?(f)
						m.directory f
					else
						m.file f, f
					end
				end
			end
			
			#m.template src, dst
			
			m.readme "INSTALL"
		end
	end

end