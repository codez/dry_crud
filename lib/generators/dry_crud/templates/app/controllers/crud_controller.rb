# Abstract controller providing basic CRUD actions.
# This implementation mainly follows the one of the Rails scaffolding
# controller and responses to HTML and JSON requests. Some enhancements were made to ease extendability.
# Several protected helper methods are there to be (optionally) overriden by subclasses.
# With the help of additional callbacks, it is possible to hook into the action procedures without
# overriding the entire method.
class CrudController < ListController

  include ERB::Util

  helper_method :entry, :full_entry_label

  delegate :model_identifier, :to => 'self.class'

  hide_action :model_identifier, :run_callbacks


  # Defines before and after callback hooks for create, update, save and destroy actions.
  define_model_callbacks :create, :update, :save, :destroy

  # Defines before callbacks for the render actions. A virtual callback
  # unifiying render_new and render_edit, called render_form, is defined further down.
  define_render_callbacks :show, :new, :edit


  ##############  ACTIONS  ############################################

  # Show one entry of this model.
  #   GET /entries/1
  #   GET /entries/1.json
  def show(&block)
    customizable_respond_with(entry, block)
  end

  # Display a form to create a new entry of this model.
  #   GET /entries/new
  #   GET /entries/new.json
  def new(&block)
    assign_attributes
    customizable_respond_with(entry, block)
  end

  # Create a new entry of this model from the passed params.
  # There are before and after create callbacks to hook into the action.
  # To customize the response, you may overwrite this action and call
  # super with a block that gets success and format parameters.
  #   POST /entries
  #   POST /entries.json
  def create(&block)
    assign_attributes
    created = with_callbacks(:create, :save) { entry.save }

    customizable_respond_to(created, block) do |format|
      if created
        format.html { redirect_to_show success_notice }
        format.json  { render :json => entry, :status => :created, :location => path_args(entry) }
      else
        format.html { render_with_callback 'new'  }
        format.json  { render :json => entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Display a form to edit an exisiting entry of this model.
  #   GET /entries/1/edit
  def edit
    render_with_callback 'edit'
  end

  # Update an existing entry of this model from the passed params.
  # There are before and after update callbacks to hook into the action.
  # To customize the response, you may overwrite this action and call
  # super with a block that gets success and format parameters.
  #   PUT /entries/1
  #   PUT /entries/1.json
  def update(&block)
    assign_attributes
    updated = with_callbacks(:update, :save) { entry.save }

    customizable_respond_to(updated, block) do |format|
      if updated
        format.html { redirect_to_show success_notice }
        format.json  { head :ok }
      else
        format.html { render_with_callback 'edit'  }
        format.json  { render :json => entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Destroy an existing entry of this model.
  # There are before and after destroy callbacks to hook into the action.
  # To customize the response, you may overwrite this action and call
  # super with a block that gets success and format parameters.
  #   DELETE /entries/1
  #   DELETE /entries/1.json
  def destroy(&block)
    destroyed = run_callbacks(:destroy) { entry.destroy }

    customizable_respond_to(destroyed, block) do |format|
      if destroyed
        format.html { redirect_to_index success_notice }
        format.json  { head :ok }
      else
        format.html { 
          flash.alert = entry.errors.full_messages.join('<br/>')
          request.env["HTTP_REFERER"].present? ? redirect_to(:back) : redirect_to_show
        }
        format.json  { render :json => entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  protected

  #############  CUSTOMIZABLE HELPER METHODS  ##############################

  # Main accessor method for the handled model entry.
  def entry
    get_model_ivar || set_model_ivar(params[:id] ? find_entry : build_entry)
  end
  
  # Creates a new model entry.
  def build_entry
    model_scope.new
  end

  # Sets an existing model entry from the given id.
  def find_entry
    model_scope.find(params[:id])
  end
  
  # Assigns the attributes from the params to the model entry.
  def assign_attributes
    entry.attributes = params[model_identifier]
  end

  # A label for the current entry, including the model name.
  def full_entry_label
    "#{models_label(false)} <i>#{h(entry)}</i>".html_safe
  end

  # Redirects to the show action of a single entry.
  def redirect_to_show(options = {})
    redirect_to path_args(entry), options
  end

  # Redirects to the main action of this controller.
  def redirect_to_index(options = {})
    redirect_to polymorphic_path(path_args(model_class), :returning => true), options
  end

  # Helper method the run the given block in between the before and after
  # callbacks of the given kinds.
  def with_callbacks(*kinds, &block)
    kinds.reverse.inject(block) do |b, kind| 
      lambda { run_callbacks(kind, &b) }
    end.call
  end
  
  private
  
  # Convenience method to respond to various formats if the performed
  # action may succeed or fail. It is possible to pass a custom_block and respond
  # in custom ways for certain cases. If no response is performed in the
  # given block, the default responses in the main block are executed.
  def customizable_respond_to(success, custom_block = nil)
    respond_to do |format|
      custom_block.call(success, format) if custom_block
      return if performed?
      
      yield format
    end
  end
  
  # Create an I18n flash notice if the action was successfull.
  # Uses the key {controller_name}.{action_name}.flash.success
  # or crud.{action_name}.flash.success as fallback.
  def success_notice
    key = "#{action_name}.flash.success"
    {:notice => t(:"#{controller_name}.#{key}", 
                  :model => full_entry_label, 
                  :default => :"crud.#{key}")}
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
