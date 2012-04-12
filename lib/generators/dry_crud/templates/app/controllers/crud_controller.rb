# Abstract controller providing basic CRUD actions.
# This implementation mainly follows the one of the Rails scaffolding
# controller and responses to HTML and JSON requests. Some enhancements were made to ease extendability.
# Several protected helper methods are there to be (optionally) overriden by subclasses.
# With the help of additional callbacks, it is possible to hook into the action procedures without
# overriding the entire method.
class CrudController < ListController

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
    respond_with(entry, &block)
  end

  # Display a form to create a new entry of this model.
  #   GET /entries/new
  #   GET /entries/new.json
  def new(&block)
    assign_attributes
    respond_with(entry, &block)
  end

  # Create a new entry of this model from the passed params.
  # There are before and after create callbacks to hook into the action.
  # To customize the response, you may overwrite this action and call
  # super with a block that gets the format parameter.
  #   POST /entries
  #   POST /entries.json
  def create(&block)
    assign_attributes
    created = with_callbacks(:create, :save) { entry.save }
    respond_with(entry, :success => created, &block)
  end

  # Display a form to edit an exisiting entry of this model.
  #   GET /entries/1/edit
  def edit(&block)
    respond_with(entry, &block)
  end

  # Update an existing entry of this model from the passed params.
  # There are before and after update callbacks to hook into the action.
  # To customize the response, you may overwrite this action and call
  # super with a block that gets the format parameter.
  #   PUT /entries/1
  #   PUT /entries/1.json
  def update(&block)
    assign_attributes
    updated = with_callbacks(:update, :save) { entry.save }
    respond_with(entry, :success => updated, &block)
  end

  # Destroy an existing entry of this model.
  # There are before and after destroy callbacks to hook into the action.
  # To customize the response, you may overwrite this action and call
  # super with a block that gets success and format parameters.
  #   DELETE /entries/1
  #   DELETE /entries/1.json
  def destroy(&block)
    destroyed = run_callbacks(:destroy) { entry.destroy }
    respond_with(entry, :success => destroyed, &block)
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
    "#{models_label(false)} <i>#{ERB::Util.h(entry)}</i>".html_safe
  end

  # The url of the index action. Includes a :returning param to use the remember_params.
  def index_url
    polymorphic_url(path_args(model_class), :returning => true)
  end

  # Url of the show action. May delegate to index_url if a subclass has no show action.
  def show_url
    polymorphic_url(path_args(entry))
  end


  private

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

  # Custom Responder that adds a flash message on success and
  # redirects to the right locations. An additional :success option
  # is used to handle action callback chain halts.
  class Responder < ActionController::Responder

    @@helper = Object.new.extend(ActionView::Helpers::TranslationHelper).
                          extend(ActionView::Helpers::OutputSafetyHelper)

    delegate :action_name, :controller_name, :to => :controller

    def initialize(controller, resources, options = {})
      super(controller, with_path_args(resources, controller), options)
    end

    protected

    # This is the common success behavior for formats associated with browsing, like :html, :iphone and so forth.
    def navigation_behavior(*args)
      set_flash
      super
    end

    # Sets a flash notice on success for put, post and delete
    # and an alert on delete failure.
    def set_flash
      if !get? && !has_errors?
        controller.flash[:notice] ||= success_notice
      elsif delete? && has_errors?
        controller.flash[:alert] ||= failure_alert
      end
    end

    # Check whether the resource has errors.
    # Additionally checks the :success option.
    def has_errors?
      options[:success] == false || super
    end

    # The location to redirect after successfull processing.
    # Redirects :back if a delete failed, to the show_url if the
    # resource exists and to index_url otherwise.
    def navigation_location
      if delete? && has_errors? && request.env["HTTP_REFERER"].present?
        :back
      elsif options[:location]
        options[:location]
      elsif controller.respond_to?(:index_url)
        if resource.respond_to?(:persisted?) && resource.persisted?
          controller.send(:show_url)
        else
          controller.send(:index_url)
        end
      else
        super
      end
    end

    # Create an I18n flash notice for a successfull action.
    # Uses the key {controller_name}.{action_name}.flash.success
    # or crud.{action_name}.flash.success as fallback.
    def success_notice
      flash_message('success')
    end

    # Create an I18n flash alert for a failed action.
    # Uses the key {controller_name}.{action_name}.flash.failure
    # or crud.{action_name}.flash.failure as fallback.
    def failure_alert
      if resource.errors.present?
        @@helper.safe_join(resource.errors.full_messages, '<br/>'.html_safe)
      else
        flash_message('failure')
      end
    end

    # Translates the flash message, considering _html keys as well.
    def flash_message(state)
      scope = "#{action_name}.flash.#{state}"
      keys = [:"#{controller_name}.#{scope}_html",
              :"#{controller_name}.#{scope}",
              :"crud.#{scope}_html",
              :"crud.#{scope}"]
      model = controller.respond_to?(:full_entry_label) ? controller.send(:full_entry_label) : entry.to_s
      @@helper.t(keys.shift, :model => model, :default => keys)
    end

    # Wraps the resources with the path_args for correct nesting.
    def with_path_args(resources, controller)
      resources.size == 1 ? Array(controller.send(:path_args, resources.first)) : resources
    end

  end

  self.responder = Responder

end
