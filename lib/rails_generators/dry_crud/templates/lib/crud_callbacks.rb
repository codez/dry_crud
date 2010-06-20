# Defines before and after callback hooks for render, create, update, save and destroy.
# When to execute the callbacks is in the responsibility of the clients of this module.
#
# The following callbacks may be defined:
# * before_create
# * after_create
# * before_update
# * after_update
# * before_save
# * after_save
# * before_destroy
# * after_destroy
# * before_render_index
# * before_render_show
# * before_render_new
# * before_render_edit
#
module CrudCallbacks
  
  def self.included(base)
    base.extend ActiveModel::Callbacks
    
    base.define_model_callbacks :create, :update, :save, :destroy
    base.define_model_callbacks :render_index, 
                                :render_show, 
                                :render_new, 
                                :render_edit, 
                                :only => :before
  end
  
  protected
  
  # Helper method the run the given block in between the before and after
  # callbacks of the given kind.
  def with_callbacks(kind, &block)
    send(:"_run_#{kind}_callbacks", &block)
  end
  
  def render_callbacks(action)
    run_callbacks(:"before_render_#{action}") do |result, object| 
      result == false || object.performed?
    end
  end
  
end