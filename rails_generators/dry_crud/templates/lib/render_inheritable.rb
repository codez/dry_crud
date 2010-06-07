# Allows one to render inheritable views and partials.
# If no view file is found for the current controller, the corresponding file
# is looked up in its superclass hierarchy. This module must only be
# included in the root controller of the desired lookup hierarchy.
# 
# By default, this module only supports direct inheritance over one level. By overriding
# the method lookup_path, you may define a custom lookup path. By providing an object
# for the 'with' parameter, this path may even be dynamic.
module RenderInheritable
  
  protected
  
  # Add inheritable_root_path method to includer
  def self.included(controller_class)
    controller_class.send(:extend, ClassMethods)
    
    controller_class.send(:class_variable_set, :@@inheritable_root_controller, controller_class)
    controller_class.cattr_reader :inheritable_root_controller
    
    controller_class.helper_method :inheritable_partial_options
  end    
  
  # Method from ActionController::Base overriden, so render_inheritable will be 
  # called if the action does not call render explicitly.   
  def default_render
    render_inheritable :action => action_name
  end
  
  # Renders an action or a partial considering the lookup path. Templates
  # specified in the :action or :partial options are looked up and the most 
  # specific one found will get rendered. The options are directly passed to 
  # the original render method.
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
    folder = self.class.find_inheritable_file(filename, default_template_format, with)        
    options[key] = folder.present? ? "#{folder}/#{file}" : file
  end
  
  module ClassMethods
    # Performs a lookup for the given filename and returns the most specific
    # folder that contains the file.
    def find_inheritable_file(filename, format = :html, with = nil)  
      inheritable_cache[format.to_sym][filename][with] ||= find_inheritable_artifact(with) do |folder|
        view_paths.find_template("#{folder}/#{filename}", format).present? rescue false
      end
    end
    
    # Performs a lookup for a controller and returns the name of the most specific one found.
    # This method is primarly usefull when given a 'with' argument, that is used
    # in a custom lookup_path. 
    def inheritable_controller(with = nil)
      c = find_inheritable_artifact(with) do |folder|
        ActionController::Routing.possible_controllers.any? { |c| c == folder }
      end
      c || inheritable_root_controller.controller_path
    end
    
    # Runs through the lookup path and yields each folder to the passed block.
    # If the block returns true, this folder is returned and no further lookup
    # happens. If no folder is found, the nil is returned.
    def find_inheritable_artifact(with = nil)
      lookup_path(with).each { |folder| return folder if yield(folder) }
      nil
    end
    
    # An array of controller names / folders, ordered from most specific to most general.
    # May be dynamic dependening on the passed 'with' argument. 
    # You may override this method in an own controller to customize the lookup path.
    def lookup_path(with = nil)
      inheritance_lookup_path
    end
    
    # The inheritance path of controllers that is used as default lookup path.
    def inheritance_lookup_path
      path = [self]
      until path.last == inheritable_root_controller
        path << path.last.superclass
      end
      path.collect(&:controller_path)
    end
    
    def inheritable_cache #:nodoc:
      @inheritable_cache ||= Hash.new {|h, k| h[k] = Hash.new {|h, k| h[k] = Hash.new } }
    end
  end
  
end
