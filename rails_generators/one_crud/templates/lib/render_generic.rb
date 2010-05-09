module RenderGeneric
    
    protected
    
    def self.included(controller_class)
        # add generic_path method to includer
        controller_class.module_eval <<-FIN
            def generic_path
                "#{controller_class.controller_path}"
            end
        FIN

        controller_class.helper_method :render_generic_partial_options, :complete_lookup_folders
    end    
        
    # method from ActionController::Base overriden    
    def default_render    
        render_generic :action => action_name
    end
       
    def render_generic(options)         
        if options[:action]
            render_generic_template_options(options)
        elsif options[:partial]
            render_generic_partial_options(options)
        end
        render options
    end
    
    def render_generic_template_options(options)
        file = options.delete(:action)
        render_generic_file_options(options, :template, file)
    end
    
    def render_generic_partial_options(options)
        render_generic_file_options(options, :partial, options[:partial])
    end
    
    def render_generic_file_options(options, key, file)
        with = options.delete(:with)
        filename = (key == :partial) ? "_#{file}" : file
        generic_folder = find_generic_file(filename, with)        
        options[key] = "#{generic_folder}/#{file}"
    end
    
    def find_generic_file(filename, with = nil)
        find_generic_artifact(with) do |folder|
            erb_file_exists?(folder, filename)
        end
    end
    
    def erb_file_exists?(folder, filename)
        view_paths.any? do |path|
            File.exists?(File.join(path, folder, "#{filename}.html.erb")) ||
            File.exists?(File.join(path, folder, "#{filename}.rhtml"))
        end
    end
        
    def generic_controller(with = nil)
        find_generic_artifact(with) do |folder|
            ActionController::Routing.possible_controllers.any? { |c| c == folder }
        end
    end
    
    def find_generic_artifact(with = nil)
        lookup_folders(with).each { |folder| return folder if yield(folder) }
        generic_path
    end
    
    def lookup_folders(with = nil)
        [controller_path]
    end
    
    def complete_lookup_folders(with = nil)
        lookup_folders(with) + [generic_path]
    end        
  
    def controller_contributor
        complete_lookup_folders.each do |folder| 
            contributor = super(folder)
            return contributor if contributor
        end    
        nil
    end

end