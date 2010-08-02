# Allows one to render inheritable views and partials.
# If no view file is found for the current controller, the corresponding file
# is looked up in its superclass hierarchy. This module must only be
# included in the root controller of the desired lookup hierarchy.
# 
# By default, this module only supports direct inheritance over one level. By overriding
# the method lookup_path, you may define a custom lookup path. By providing an object
# for the 'with' parameter, this path may even be dynamic.
module RenderInheritable
  
  # Add inheritable_root_path method to including controller.
  def self.included(controller_class)
    controller_class.send(:extend, ClassMethods)
    
    controller_class.send(:class_variable_set, :@@inheritable_root_controller, controller_class)
    controller_class.cattr_reader :inheritable_root_controller
  end    
  
  # Performs a lookup for the given filename and returns the most specific
  # folder that contains the file.
  def find_inheritable_template_folder(name, partial = false)
    self.class.find_inheritable_template_folder(view_context, name, partial, formats, template_lookup_param)
  end
  
  # Override this method to specify a dynamic parameter used in the lookup path.
  # For the default inheritance lookup, this parameter is not needed.
  def template_lookup_param
    nil
  end
  
  module ClassMethods
    # Performs a lookup for the given filename and returns the most specific
    # folder that contains the file.
    def find_inheritable_template_folder(view_context, name, partial, formats, param = nil)  
      find_inheritable_template_folder_cached(view_context, name, partial, formats, param) do
        find_inheritable_artifact(param) do |folder|
          view_context.template_exists?(name, folder, partial)
        end
      end
    end
    
    # Performs a lookup for a controller and returns the name of the most specific one found.
    # This method is primarly usefull when given a 'param' argument that is used
    # in a custom #template_lookup_path. In this case, no controller class would need to 
    # exist to render templates from corresponding view folders.
    def inheritable_controller(param = nil)
      descendants = inheritable_root_controller.descendants
      c = find_inheritable_artifact(param) do |folder|
      	descendants.any? { |s| s.controller_path == folder }
      end
      c || inheritable_root_controller.controller_path
    end
    
    # Runs through the lookup path and yields each folder to the passed block.
    # If the block returns true, this folder is returned and no further lookup
    # happens. If no folder is found, the nil is returned.
    def find_inheritable_artifact(param = nil)
      template_lookup_path(param).each { |folder| return folder if yield(folder) }
      nil
    end
    
    # An array of controller names / folders, ordered from most specific to most general.
    # May be dynamic dependening on the passed 'param' argument. 
    # You may override this method in an own controller to customize the lookup path.
    def template_lookup_path(param = nil)
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
    
    # Override view context class to includes the render inheritable modules.
    def view_context_class
      @view_context_class ||= begin
        Class.new(super) do
          include RenderInheritable::View
        end
      end
    end
    
    private
    
    # Performs a lookup for a template folder using the cache.
    def find_inheritable_template_folder_cached(view_context, name, partial, formats, param = nil)
      prefix = inheritable_cache_get(formats, name, partial, param)
      return prefix if prefix
      
      prefix = yield
      
      if prefix
        template = view_context.find_template_without_lookup(name, prefix, partial)
        inheritable_cache_set(template.formats, name, partial, param, prefix)
      end
      prefix
    end
    
    # A simple template lookup cache for each controller.
    def inheritable_cache #:nodoc:
      # do not store keys on each access, only return default structure
      @inheritable_cache ||= Hash.new do |h1, k1| 
        Hash.new do |h2, k2| 
          Hash.new do |h3, k3| 
            Hash.new 
          end
        end
      end
    end
    
    # Gets the prefix from the cache. Returns nil if it's not there yet.
    def inheritable_cache_get(formats, name, partial, param)
      prefixes = formats.collect { |format| inheritable_cache[format.to_sym][partial][name][param] }
      prefixes.compact!
      prefixes.empty? ?  nil : prefixes.first
    end
    
    # Stores the found prefix in the cache.
    def inheritable_cache_set(formats, name, partial, param, prefix)
      formats.each do |format|
        # assign hash default values to respective key 
        inheritable_cache[format.to_sym] = hf = inheritable_cache[format.to_sym]
        hf[partial] = hp = hf[partial]
        hp[name] = hn = hp[name]
        # finally store prefix in the deepest hash
        hn[param] = prefix
      end
    end
    
  end
  
  # Extend ActionView so templates are looked up on a find_template call.
  module View
    def self.included(base)
      base.send :alias_method_chain, :find_template, :lookup
    end
    
    # Perform a template lookup if the prefix corresponds to the current controller's path.
    def find_template_with_lookup(name, prefix = nil, partial = false)
      if prefix == controller_path
        folder = controller.find_inheritable_template_folder(name, partial)
        prefix = folder if folder
      end
      find_template_without_lookup(name, prefix, partial)
    end
  end
  
end
