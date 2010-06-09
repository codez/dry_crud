# Abstract controller providing basic CRUD actions.
# This implementation mainly follows the one of the Rails scaffolding
# controller. Some enhancements were made to ease extendability.
# Several protected helper methods are there to be (optionally) overriden by subclasses.
class CrudController < ApplicationController
  
  include CrudCallbacks
  include RenderInheritable 
  
  delegate :model_class, :model_identifier, :models_label, :to => 'self.class'  

  # Verify that required :id param is present and only allow good http methods.
  verify :params => :id, :only => :show, :redirect_to => { :action => 'index' }
  verify :method => :post, :only => :create,  :redirect_to => { :action => 'index' }  
  verify :method => [:put, :post], :params => :id, :only => :update,  :redirect_to => { :action => 'index' }  
  verify :method => [:delete, :post], :params => :id, :only => :destroy, :redirect_to => { :action => 'index' }  
  
  # Set up entry object to use in the various actions.
  before_filter :build_entry, :only => [:new, :create]
  before_filter :set_entry,   :only => [:show, :edit, :update, :destroy]
  
  helper_method :model_class, :models_label, :full_entry_label
  
  hide_action :model_class, :models_label, :model_identifier, :run_callbacks, :inheritable_root_controller
  
   
  ##############  ACTIONS  ############################################
  
  # List all entries of this model.
  #   GET /entries
  #   GET /entries.xml
  def index
    @entries = model_class.all find_all_options
    respond_with @entries
  end
  
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
    respond_with @entry
  end
  
  # Display a form to edit an exisiting entry of this model.
  #   GET /entries/1/edit
  def edit
    render_with_callback :edit
  end
  
  # Create a new entry of this model from the passed params.
  #   POST /entries
  #   POST /entries.xml
  def create
    created = with_callbacks(:create) { save_entry } 
    
    respond_processed(created, 'created', 'new') do |format|
      format.html { redirect_to_show }
      format.xml  { render :xml => @entry, :status => :created, :location => @entry }
    end
  end
  
  # Update an existing entry of this model from the passed params.
  #   PUT /entries/1
  #   PUT /entries/1.xml
  def update
    @entry.attributes = params[model_identifier]
    updated = with_callbacks(:update) { save_entry }
    
    respond_processed(updated, 'updated', 'edit') do |format|
      format.html { redirect_to_show }
      format.xml  { head :ok }
    end
  end
  
  # Destroy an existing entry of this model.
  #   DELETE /entries/1
  #   DELETE /entries/1.xml
  def destroy
    destroyed = with_callbacks(:destroy) { @entry.destroy }
    
    respond_processed(destroyed, 'destroyed', 'show') do |format|
      format.html { redirect_to_index }
      format.xml  { head :ok }
    end
  end
  
  protected 
  
  #############  CUSTOMIZABLE HELPER METHODS  ##############################
  
  # Convenience method to respond to various formats with the given object.
  def respond_with(object)
    respond_to do |format|
      format.html { render_with_callback action_name }
      format.xml  { render :xml => object }
    end
  end
  
  # Convenience method to respond to various formats if the performed
  # action may succeed or fail. In case of failure, a standard response
  # is given and the failed_action template is rendered. In case of success,
  # the flash[:notice] is set and control is passed to the given block.
  def respond_processed(success, operation, failed_action)
    respond_to do |format|
      if success
        flash[:notice] = "#{full_entry_label} was successfully #{operation}."
        yield format
      else 
        format.html { render_with_callback failed_action }
        format.xml  { render :xml => @entry.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # Creates a new model entry from the given params.
  def build_entry        
    @entry = model_class.new(params[model_identifier])
  end
  
  # Sets an existing model entry from the given id.
  def set_entry
    @entry = model_class.find(params[:id])
  end     
  
  # A label for the current entry, including the model name.
  def full_entry_label        
	  "#{models_label.singularize} '#{@entry.label}'"
  end    
  
  # Find options used in the index action.
  def find_all_options
    {}
  end
  
  # Redirects to the show action of a single entry.
  def redirect_to_show
    redirect_to @entry
  end
  
  # Redirects to the main action of this controller.
  def redirect_to_index
    redirect_to :action => 'index'
  end
   
  # Helper method to run before_render callbacks and render the action.
  # If a callback renders or redirects, the action is not rendered.
  def render_with_callback(action)
    render_callbacks(action)
    render_inheritable :action => action unless performed?
  end
  
  # Saves the current entry with callbacks.
  def save_entry       
    with_callbacks(:save) { @entry.save }
  end   
  
  class << self
    # The ActiveRecord class of the model.
    def model_class
      @model_class ||= controller_name.classify.constantize
    end
    
    # The identifier of the model used for form parameters.
    # I.e., the symbol of the underscored model name.
    def model_identifier
      @model_identifier ||= model_class.name.underscore.to_sym
    end
    
    # A human readable plural name of the model.
    def models_label
      @models_label ||= model_class.human_name.pluralize
    end   
  end
  
end
