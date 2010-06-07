# Defines before and after callback hooks for render, create, update, save and destroy.
# When to execute the callbacks is in the responsibility of the clients of this module.
module CrudCallbacks
  
  def self.included(base)
    base.send :include, ActiveSupport::Callbacks
    
    base.define_callbacks :before_create,  :after_create, 
      						        :before_update,  :after_update, 
      						        :before_save,    :after_save, 
      						        :before_destroy, :after_destroy,
                          :before_render_index,
                          :before_render_show,
                          :before_render_new,
                          :before_render_edit
  end
  
  protected
  
  # Helper method the run the given block in between the before and after
  # callbacks of the given kind.
  def with_callbacks(kind)
    return false if callbacks("before_#{kind}".to_sym) == false        
    if result = yield
      callbacks("after_#{kind}".to_sym)
    end
    result
  end
  
  def callbacks(kind)
    run_callbacks(kind) { |result, object| false == result }
  end
  
end