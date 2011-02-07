# Abstract controller providing basic CRUD actions.
# This implementation mainly follows the one of the Rails scaffolding
# controller and responses to HTML and XML requests. Some enhancements were made to ease extendability.
# Several protected helper methods are there to be (optionally) overriden by subclasses.
# With the help of additional callbacks, it is possible to hook into the action procedures without
# overriding the entire method.
class CrudController < ListController
    
  # Set up entry object to use in the various actions.
  before_filter :build_entry, :only => [:new, :create]
  before_filter :set_entry,   :only => [:show, :edit, :update, :destroy]
  
  helper_method :full_entry_label
  
  delegate :model_identifier, :to => 'self.class'  
  
  hide_action :model_identifier, :run_callbacks
   
   
  # Defines before and after callback hooks for create, update, save and destroy.
  define_model_callbacks :create, :update, :save, :destroy
  
  # Defines before callbacks for the render actions. A virtual callback
  # unifiying render_new and render_edit, called render_form, is defined further down.
  define_model_callbacks :render_show, 
                         :render_new, 
                         :render_edit, 
                         :only => :before,
                         :terminator => "result == false || performed?"
                         
  # Verify that required :id param is present and only allow good http methods.
  # Uncomment if you have the Rails verification plugin installed.
  #verify :params => :id, :only => :show, :redirect_to => { :action => 'index' }
  #verify :method => :post, :only => :create,  :redirect_to => { :action => 'index' }  
  #verify :method => [:put, :post], :params => :id, :only => :update,  :redirect_to => { :action => 'index' }  
  #verify :method => [:delete, :post], :params => :id, :only => :destroy, :redirect_to => { :action => 'index' }  
  
   
  ##############  ACTIONS  ############################################

  
  # Show one entry of this model.
  #   GET /entries/1
  #   GET /entries/1.xml
  def show
    respond_with @entry
  end
  
  # Display a form to create a new entry of this model.
  #   GET /entries/new
  #   GET /entries/new.xml
  def new
    @entry.attributes = params[model_identifier]
    respond_with @entry
  end

  # Create a new entry of this model from the passed params.
  #   POST /entries
  #   POST /entries.xml
  def create
    @entry.attributes = params[model_identifier]
    created = with_callbacks(:create) { save_entry } 
    
    respond_processed(created, 'created', 'new') do |format|
      format.xml  { render :xml => @entry, :status => :created, :location => @entry } if created
    end
  end
    
  # Display a form to edit an exisiting entry of this model.
  #   GET /entries/1/edit
  def edit
    render_with_callback 'edit'
  end
  
  # Update an existing entry of this model from the passed params.
  #   PUT /entries/1
  #   PUT /entries/1.xml
  def update
    @entry.attributes = params[model_identifier]
    updated = with_callbacks(:update) { save_entry }
    
    respond_processed(updated, 'updated', 'edit')
  end
  
  # Destroy an existing entry of this model.
  #   DELETE /entries/1
  #   DELETE /entries/1.xml
  def destroy
    destroyed = with_callbacks(:destroy) { @entry.destroy }

    respond_processed(destroyed, 'destroyed') do |format|
      format.html do 
        if destroyed
          redirect_to_index
        else
          flash.alert = @entry.errors.full_messages.join('<br/>').html_safe
          request.env["HTTP_REFERER"].present? ? redirect_to(:back) : redirect_to_show
        end
      end
    end
  end
  
  protected 
  
  #############  CUSTOMIZABLE HELPER METHODS  ##############################
  
  # Convenience method to respond to various formats if the performed
  # action may succeed or fail. It is possible to pass a block and respond
  # in custom ways for certain cases. If no response is performed in the 
  # given block, the default responses in this method are executed.
  def respond_processed(success, operation, failed_action = 'show')
    respond_to do |format|
      flash.notice = "#{full_entry_label} was successfully #{operation}." if success
      yield format if block_given?
      return if performed?
      
      # fallback responders if nothing was performed in the block
      if success
        format.html { redirect_to_show }
        format.xml  { head :ok }
      else 
        format.html { render_with_callback failed_action }
        format.xml  { render :xml => @entry.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # Creates a new model entry.
  def build_entry
    @entry = model_class.new
  end
  
  # Sets an existing model entry from the given id.
  def set_entry
    @entry = model_class.find(params[:id])
  end
  
  # A label for the current entry, including the model name.
  def full_entry_label
    "#{models_label.singularize} '#{@entry.label}'"
  end
   
  # Redirects to the show action of a single entry.
  def redirect_to_show
    redirect_to @entry
  end
  
  # Redirects to the main action of this controller.
  def redirect_to_index
    redirect_to polymorphic_path(model_class, :returning => true)
  end
  
  # Saves the current entry with callbacks.
  def save_entry
    with_callbacks(:save) { @entry.save }
  end
  
  # Helper method the run the given block in between the before and after
  # callbacks of the given kind.
  def with_callbacks(kind, &block)
    send(:"_run_#{kind}_callbacks", &block)
  end
  
  class << self
    # The identifier of the model used for form parameters.
    # I.e., the symbol of the underscored model name.
    def model_identifier
      @model_identifier ||= model_class.name.underscore.to_sym
    end

    # Convenience callback to apply a callback on both form actions (new and edit).
    def before_render_form(*methods)
      before_render_new *methods
      before_render_edit *methods
    end
  end
  
end
