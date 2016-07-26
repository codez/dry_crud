# encoding: UTF-8

# Abstract controller providing basic CRUD actions.
#
# Some enhancements were made to ease extensibility.
# The current model entry is available in the view as an instance variable
# named after the +model_class+ or in the helper method +entry+.
# Several protected helper methods are there to be (optionally) overriden by
# subclasses.
# With the help of additional callbacks, it is possible to hook into the
# action procedures without overriding the entire method.
class CrudController < ListController

  class_attribute :permitted_attrs

  # Defines before and after callback hooks for create, update, save and
  # destroy actions.
  define_model_callbacks :create, :update, :save, :destroy

  # Defines before callbacks for the render actions. A virtual callback
  # unifiying render_new and render_edit, called render_form, is defined
  # further down.
  define_render_callbacks :show, :new, :edit

  before_action :entry, only: [:show, :new, :edit, :update, :destroy]

  helper_method :entry, :full_entry_label

  ##############  ACTIONS  ############################################

  #   GET /entries/1
  #   GET /entries/1.json
  #
  # Show one entry of this model.
  def show
  end

  #   GET /entries/new
  #   GET /entries/new.json
  #
  # Display a form to create a new entry of this model.
  def new
    assign_attributes if params[model_identifier]
  end

  #   POST /entries
  #   POST /entries.json
  #
  # Create a new entry of this model from the passed params.
  # There are before and after create callbacks to hook into the action.
  #
  # To customize the response for certain formats, you may overwrite
  # this action and call super with a block that gets the format and
  # success parameters. Calling a format action (e.g. format.html)
  # in the given block will take precedence over the one defined here.
  #
  # Specify a :location option if you wish to do a custom redirect.
  def create(options = {}, &_block)
    assign_attributes
    created = with_callbacks(:create, :save) { entry.save }

    respond_to do |format|
      yield(format, created) if block_given?
      if created
        format.html { redirect_on_success(options) }
        format.json { render :show, status: :created, location: show_path }
      else
        format.html { render :new }
        format.json { render json: entry.errors, status: :unprocessable_entity }
      end
    end
  end

  #   GET /entries/1/edit
  #
  # Display a form to edit an exisiting entry of this model.
  def edit
  end

  #   PUT /entries/1
  #   PUT /entries/1.json
  #
  # Update an existing entry of this model from the passed params.
  # There are before and after update callbacks to hook into the action.
  #
  # To customize the response for certain formats, you may overwrite
  # this action and call super with a block that gets the format and
  # success parameters. Calling a format action (e.g. format.html)
  # in the given block will take precedence over the one defined here.
  #
  # Specify a :location option if you wish to do a custom redirect.
  def update(options = {}, &_block)
    assign_attributes
    updated = with_callbacks(:update, :save) { entry.save }

    respond_to do |format|
      yield(format, updated) if block_given?
      if updated
        format.html { redirect_on_success(options) }
        format.json { render :show, status: :ok, location: show_path }
      else
        format.html { render :edit }
        format.json { render json: entry.errors, status: :unprocessable_entity }
      end
    end
  end

  #   DELETE /entries/1
  #   DELETE /entries/1.json
  #
  # Destroy an existing entry of this model.
  # There are before and after destroy callbacks to hook into the action.
  #
  # To customize the response for certain formats, you may overwrite
  # this action and call super with a block that gets format and
  # success parameters. Calling a format action (e.g. format.html)
  # in the given block will take precedence over the one defined here.
  #
  # Specify a :location option if you wish to do a custom redirect.
  def destroy(options = {}, &_block)
    destroyed = run_callbacks(:destroy) { entry.destroy }

    respond_to do |format|
      yield(format, destroyed) if block_given?
      if destroyed
        format.html { redirect_on_success(options) }
        format.json { head :no_content }
      else
        format.html { redirect_on_failure(options) }
        format.json { render json: entry.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  #############  CUSTOMIZABLE HELPER METHODS  ##############################

  # Main accessor method for the handled model entry.
  def entry
    model_ivar_get || model_ivar_set(params[:id] ? find_entry : build_entry)
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
    entry.attributes = model_params
  end

  # The form params for this model.
  def model_params
    params.require(model_identifier).permit(permitted_attrs)
  end

  # Path of the index page to return to.
  def index_path
    polymorphic_path(path_args(model_class), returning: true)
  end

  # Path of the show page.
  def show_path
    path_args(entry)
  end

  # Perform a redirect after a successfull operation and set a flash notice.
  def redirect_on_success(options = {})
    location = options[:location] ||
               (entry.destroyed? ? index_path : show_path)
    flash[:notice] ||= flash_message(:success)
    redirect_to location
  end

  # Perform a redirect after a failed operation and set a flash alert.
  def redirect_on_failure(options = {})
    location = options[:location] ||
               request.env['HTTP_REFERER'].presence ||
               index_path
    flash[:alert] ||= error_messages.presence || flash_message(:failure)
    redirect_to location
  end

  # Get an I18n flash message.
  # Uses the key {controller_name}.{action_name}.flash.{state}
  # or crud.{action_name}.flash.{state} as fallback.
  def flash_message(state)
    scope = "#{action_name}.flash.#{state}"
    keys = [:"#{controller_name}.#{scope}_html",
            :"#{controller_name}.#{scope}",
            :"crud.#{scope}_html",
            :"crud.#{scope}"]
    I18n.t(keys.shift, model: full_entry_label, default: keys)
  end

  # A label for the current entry, including the model name.
  def full_entry_label
    # rubocop:disable Rails/OutputSafety
    "#{models_label(false)} <i>#{ERB::Util.h(entry)}</i>".html_safe
    # rubocop:enable Rails/OutputSafety
  end

  # Html safe error messages of the current entry.
  def error_messages
    # rubocop:disable Rails/OutputSafety
    escaped = entry.errors.full_messages.map { |m| ERB::Util.html_escape(m) }
    escaped.join('<br/>').html_safe
    # rubocop:enable Rails/OutputSafety
  end

  # Class methods for CrudActions.
  class << self
    # Convenience callback to apply a callback on both form actions
    # (new and edit).
    def before_render_form(*methods)
      before_render_new(*methods)
      before_render_edit(*methods)
    end
  end

end
