# Include this module in a controller with subclasses to get inheritable templates and partials.
# If the view file is not found for the current subclass, the corresponding file from the superclass
# is used.
# 
# By default, this module only supports direct inheritance over one level. By overriding
# the method lookup_path, you may define a custom lookup path. By providing an object
# for the 'with' parameter, this path may even be dynamic.
module RenderInheritable
    
    protected
    
    # Add inheritable_root_path method to includer
    def self.included(controller_class)
        controller_class.module_eval <<-FIN
            # The root folder where all lookups end. This folder
            # should contain a file for all templates used with render_inheritable.
            # Returns the folder of the controller that includes RenderInheritable by default.
            def inheritable_root_folder
                "#{controller_class.controller_path}"
            end
        FIN

        controller_class.helper_method :inheritable_partial_options, :complete_lookup_path
    end    
        
    # Method from ActionController::Base overriden, so render_inheritable will be 
    # called if the action does not call render explicitly.   
    def default_render    
        render_inheritable :action => action_name
    end
       
    # Renders an action or a partial considering the lookup path. The
    # :action or :partial file is looked up and the most specific one found
    # will get rendered.
    def render_inheritable(options)         
        if options[:action]
            inheritable_template_options(options)
        elsif options[:partial]
            inheritable_partial_options(options)
        end
        render options
    end
    
    # Replaces the :template option with the file found in the lookup.
    def inheritable_template_options(options)
        file = options.delete(:action)
        inheritable_file_options(options, :template, file)
    end
    
    # Replaces the :partial option with the file found in the lookup.
    def inheritable_partial_options(options)
        inheritable_file_options(options, :partial, options[:partial])
    end
    
    def inheritable_file_options(options, key, file) #:nodoc:
        with = options.delete(:with)
        filename = (key == :partial) ? "_#{file}" : file
        folder = find_inheritable_file(filename, with)        
        options[key] = "#{folder}/#{file}"
    end
    
    # Performs a lookup for the given filename and returns the most specific
    # folder that contains the file.
    def find_inheritable_file(filename, with = nil)
        find_inheritable_artifact(with) do |folder|
            erb_file_exists?(folder, filename)
        end
    end
    
    # Checks whether an erb file exists in the given folder.
    def erb_file_exists?(folder, filename)
        view_paths.any? do |path|
            base = File.join(path, folder, filename)
            File.exists?("#{base}.html.erb") || File.exists?("#{base}.rhtml")
        end
    end
        
    # Performs a lookup for a controller and returns the most specific one found.
    # This method is primarly usefull when given a 'with' argument, that is used
    # in a custom lookup_path. 
    def inheritable_controller(with = nil)
        find_inheritable_artifact(with) do |folder|
            ActionController::Routing.possible_controllers.any? { |c| c == folder }
        end
    end
    
    # Runs through the lookup path and yields each folder to the passed block.
    # If the block returns true, this folder is returned and no further lookup
    # happens. If no folder is found, the inheritable_root_folder is returned.
    def find_inheritable_artifact(with = nil)
        lookup_path(with).each { |folder| return folder if yield(folder) }
        inheritable_root_folder
    end
    
    # An array of controller names / folders, ordered from most specific to most general.
    # May be dynamic dependening on the passed 'with' argument. Does not contain
    # the inheritable_root_folder.
    def lookup_path(with = nil)
        [controller_path]
    end
    
    # Lookup path with inheritable_root_folder appended.
    def complete_lookup_path(with = nil)
        lookup_path(with) + [inheritable_root_folder]
    end        

end