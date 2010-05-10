# CrudController is an abstract controller providing basic CRUD actions.
# Several protected helper methods are there to be (optionally) overriden by subclasses.
class CrudController < ApplicationController
  
  include CrudCallbacks
  include RenderGeneric    
  
  verify :method => :post,   :only => :create,  :redirect_to => { :action => 'index' }  
  verify :method => :put,    :only => :update,  :redirect_to => { :action => 'index' }  
  verify :method => :delete, :only => :destroy, :redirect_to => { :action => 'index' }  
  
  before_filter :build_entry, :only => [:new, :create]
  before_filter :set_entry,   :only => [:show, :edit, :update, :remove, :destroy]
  
  helper_method :model_class, :models_label, :full_entry_label
  
  hide_action :model_class, :models_label, :full_entry_label
  
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
    respond_to do |format|
      if with_callbacks(:create) { save_entry } 
        flash[:notice] = "#{full_entry_label} was successfully created."
        format.html { redirect_to(@entry) }
        format.xml  { render :xml => @entry, :status => :created, :location => @entry }
      else
        format_error(format, 'new')
      end
    end
  end
  
  # PUT /entries/1
  # PUT /entries/1.xml
  def update
    @entry.attributes = params[:entry]
    
    respond_to do |format|
      if with_callbacks(:update) { save_entry }
        flash[:notice] = "#{full_entry_label} was successfully updated."
        format.html { redirect_to(@entry) }
        format.xml  { head :ok }
      else
        format_error(format, 'edit')
      end
    end
  end
  
  # DELETE /entries/1
  # DELETE /entries/1.xml
  def destroy
    respond_to do |format|
      if with_callbacks(:destroy) { @entry.destroy }
        flash[:notice] = "#{full_entry_label} was successfully removed."
        
        format.html { redirect_to(:action => 'index') }
        format.xml  { head :ok }
      else
        format_error(format, 'show')
      end
    end
  end
  
  protected 
  
  #############  CUSTOMIZABLE HELPER METHODS  ##############################
  
  def respond_with(object)
    respond_to do |format|
      format.html { render_generic :action => action_name }
      format.xml  { render :xml => object }
    end
  end
  
  def format_error(format, render_action)
    format.html { render_generic :action => render_action }
    format.xml  { render :xml => @entry.errors, :status => :unprocessable_entity }
  end
  
  def build_entry        
    @entry = model_class.new(params[:entry])
  end
  
  def set_entry
    @entry = model_class.find(params[:id])
  end
  
  def model_class
    controller_name.classify.constantize
  end
  
  def models_label
    controller_name.humanize.titleize
  end        
  
  def full_entry_label        
	"#{models_label.singularize} #{@entry.label}"
  end    
  
  def save_entry       
    with_callbacks(:save) {	@entry.save }
  end   
  
  def fetch_all_options
    {}
  end
  
end
