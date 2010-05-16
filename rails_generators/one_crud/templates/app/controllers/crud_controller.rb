# CrudController is an abstract controller providing basic CRUD actions.
# Several protected helper methods are there to be (optionally) overriden by subclasses.
class CrudController < ApplicationController
  
  include CrudCallbacks
  include RenderInheritable 
  
  verify :params => :id, :only => :show, :redirect_to => { :action => 'index' }
  verify :method => :post, :only => :create,  :redirect_to => { :action => 'index' }  
  verify :method => [:put, :post], :params => :id, :only => :update,  :redirect_to => { :action => 'index' }  
  verify :method => [:delete, :post], :params => :id, :only => :destroy, :redirect_to => { :action => 'index' }  
  
  before_filter :build_entry, :only => [:new, :create]
  before_filter :set_entry,   :only => [:show, :edit, :update, :remove, :destroy]
  
  helper_method :model_class, :models_label, :full_entry_label
   
  ##############  ACTIONS  ############################################
  
  # GET /entries
  # GET /entries.xml
  def index
    @entries = model_class.find :all, fetch_all_options
    respond_with @entries
  end
  
  # GET /entries/1
  # GET /entries/1.xml
  def show
    respond_with @entry
  end
  
  # GET /entries/new
  # GET /entries/new.xml
  def new
    respond_with @entry
  end
  
  # GET /entries/1/edit
  def edit
  end
  
  # POST /entries
  # POST /entries.xml
  def create
    created = with_callbacks(:create) { save_entry } 
    
    respond_processed(created, 'created', 'new') do |format|
      format.html { redirect_to(@entry) }
      format.xml  { render :xml => @entry, :status => :created, :location => @entry }
    end
  end
  
  # PUT /entries/1
  # PUT /entries/1.xml
  def update
    @entry.attributes = params[model_identifier]
    updated = with_callbacks(:update) { save_entry }
    
    respond_processed(updated, 'updated', 'edit') do |format|
      format.html { redirect_to(@entry) }
      format.xml  { head :ok }
    end
  end
  
  # DELETE /entries/1
  # DELETE /entries/1.xml
  def destroy
    destroyed = with_callbacks(:destroy) { @entry.destroy }
    
    respond_processed(destroyed, 'destroyed', 'show') do |format|
      format.html { redirect_to(:action => 'index') }
      format.xml  { head :ok }
    end
  end
  
  protected 
  
  #############  CUSTOMIZABLE HELPER METHODS  ##############################
  
  def respond_with(object)
    respond_to do |format|
      format.html { render_inheritable :action => action_name }
      format.xml  { render :xml => object }
    end
  end
  
  def respond_processed(success, operation, failed_action)
    respond_to do |format|
      if success
        flash[:notice] = "#{full_entry_label} was successfully #{operation}."
        yield format
      else 
        format.html { render_inheritable :action => failed_action }
        format.xml  { render :xml => @entry.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def build_entry        
    @entry = model_class.new(params[model_identifier])
  end
  
  def set_entry
    @entry = model_class.find(params[:id])
  end
  
  def model_identifier
    @model_identifier ||= controller_name.singularize.to_sym
  end
  
  def model_class
    @model_class ||= controller_name.classify.constantize
  end
  
  def models_label
    @models_label ||= controller_name.humanize.titleize
  end        
  
  def full_entry_label        
	  "#{models_label.singularize} '#{@entry.label}'"
  end    
  
  def save_entry       
    with_callbacks(:save) {	@entry.save }
  end   
  
  def fetch_all_options
    {}
  end
  
end
