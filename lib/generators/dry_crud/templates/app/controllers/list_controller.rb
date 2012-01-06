# Abstract controller providing a basic list action.
# This action lists all entries of a certain model and provides functionality to
# search and sort this list.
# Furthermore, it remembers the last search and sort parameters. When the action
# is called with a param returning=true, these parameters are reused to present
# the user the same list as he left it.
class ListController < ApplicationController

  helper_method :model_class, :models_label, :path_entry

  delegate :model_class, :models_label, :to => 'self.class'

  hide_action :model_class, :models_label, :inheritable_root_controller


  ##############  ACTIONS  ############################################

  # List all entries of this model.
  #   GET /entries
  #   GET /entries.json
  def index
    @entries = list_entries
    respond_with @entries
  end

  protected

  # The entries to be displayed in the current index page.
  def list_entries
    model_scope
  end
  
  # The scope where model entries will be listed and created.
  # This is mainly used for nested models to provide the 
  # required context.
  def model_scope
    model_class.scoped
  end
  
  # The path arguments to link to the given entry.
  # If the controller is nested, this provides the required context.
  def path_entry(entry = @entry)
    entry
  end

  # Convenience method to respond to various formats with the given object.
  def respond_with(object)
    respond_to do |format|
      format.html { render_with_callback action_name }
      format.json  { render :json => object }
    end
  end

  # Helper method to run before_render callbacks and render the action.
  # If a callback renders or redirects, the action is not rendered.
  def render_with_callback(action)
    run_callbacks(:"render_#{action}")
    render action unless performed?
  end

  class << self
    # Callbacks
    include ActiveModel::Callbacks
   
    # The ActiveRecord class of the model.
    def model_class
      @model_class ||= controller_name.classify.constantize
    end

    # A human readable plural name of the model.
    def models_label(plural = true)
      opts = {:count => (plural ? 3 : 1)}
      opts[:default] = model_class.model_name.human.pluralize if plural
      model_class.model_name.human(opts)
    end
    
    # Defines before callbacks for the render actions.
    def define_render_callbacks(*actions)
      args = actions.collect {|a| :"render_#{a}" }
      args << {:only => :before,
               :terminator => "result == false || performed?"}
      define_model_callbacks *args
    end
  end
  
  define_render_callbacks :index

  # The search functionality for the index table.
  # Extracted into an own module for convenience.
  module Search
    def self.included(controller)
      # Define an array of searchable columns in your subclassing controllers.
      controller.class_attribute :search_columns
      controller.search_columns = []

      controller.helper_method :search_support?

      controller.alias_method_chain :list_entries, :search
    end

    protected

    # Enhance the list entries with an optional search criteria
    def list_entries_with_search
      list_entries_without_search.where(search_condition)
    end

    # Compose the search condition with a basic SQL OR query.
    def search_condition
      if search_support? && params[:q].present?
        terms = params[:q].split(/\s+/).collect { |t| "%#{t}%" }
        clause = search_columns.collect do |f| 
          col = f.to_s.include?('.') ? f : "#{model_class.table_name}.#{f}"
          "#{col} LIKE ?"
        end.join(" OR ")
        clause = terms.collect {|t| "(#{clause})" }.join(" AND ")
        
         ["(#{clause})"] + terms.collect {|t| [t] * search_columns.size }.flatten
      end
    end

    # Returns true if this controller has searchable columns.
    def search_support?
      search_columns.present?
    end

  end

  include Search

  # Sort functionality for the index table.
  # Extracted into an own module for convenience.
  module Sort
    # Adds a :sort_mappings class attribute.
    def self.included(controller)
      # Define a map of (virtual) attributes to SQL order expressions.
      # May be used for sorting table columns that do not appear directly
      # in the database table. E.g., map :city_id => 'cities.name' to
      # sort the displayed city names.
      controller.class_attribute :sort_mappings
      controller.sort_mappings = {}

      controller.helper_method :sortable?

      controller.alias_method_chain :list_entries, :sort
    end

    protected

    # Enhance the list entries with an optional sort order.
    def list_entries_with_sort
      if params[:sort].present? && sortable?(params[:sort])
        list_entries_without_sort.reorder(sort_expression)
      else
        list_entries_without_sort
      end
    end

    # Return the sort expression to be used in the list query.
    def sort_expression
      col = sort_mappings[params[:sort].to_sym] ||
            "#{model_class.table_name}.#{params[:sort]}"
      "#{col} #{sort_dir}"
    end

    # The sort direction, either 'asc' or 'desc'.
    def sort_dir
      params[:sort_dir] == 'desc' ? 'desc' : 'asc'
    end

    # Returns true if the passed attribute is sortable.
    def sortable?(attr)
      model_class.column_names.include?(attr.to_s) ||
      sort_mappings.include?(attr.to_sym)
    end
  end

  include Sort

  # Remembers certain params of the index action in order to return
  # to the same list after an entry was viewed or edited.
  # If the index is called with a param :returning, the remembered params
  # will be re-used.
  # Extracted into an own module for convenience.
  module Memory

    # Adds the :remember_params class attribute and a before filter to the index action.
    def self.included(controller)
      # Define a list of param keys that should be remembered for the list action.
      controller.class_attribute :remember_params
      controller.remember_params = [:q, :sort, :sort_dir]

      controller.before_filter :handle_remember_params, :only => [:index]
    end

    private

    # Store and restore the corresponding params.
    def handle_remember_params
      remembered = remembered_params

      restore_params_on_return(remembered)
      store_current_params(remembered)
      clear_void_params(remembered)
    end

    def restore_params_on_return(remembered)
      if params[:returning]
        remember_params.each {|p| params[p] ||= remembered[p] }
      end
    end

    def store_current_params(remembered)
      remember_params.each do |p|
        remembered[p] = params[p].presence
        remembered.delete(p) if remembered[p].nil?
      end
    end

    def clear_void_params(remembered)
      session[:list_params].delete(remember_key) if remembered.blank?
    end

    # Get the params stored in the session.
    def remembered_params
      session[:list_params] ||= {}
      session[:list_params][remember_key] ||= {}
    end
    
    # Params are stored by request path to play nice when a controller
    # is used in different routes.
    def remember_key
       request.path
    end
  end

  include Memory

  # TODO: comments
  module Nested
    def self.included(controller)
      controller.class_attribute :nested
      
      controller.alias_method_chain :model_scope, :nested
      controller.alias_method_chain :path_entry, :nested
    end
    
    protected
    
    def parents
      @parents ||= Array(nested).collect do |p|
        if p < ActiveRecord::Base
          p.find(params["#{p.name.underscore}_id"])
        else
          p
        end
      end
    end
    
    private
    
    def path_entry_with_nested(entry = @entry)
      parents + [entry]
    end
    
    def model_scope_with_nested
      ar = parents.select {|p| p.is_a?(ActiveRecord::Base) }
      if ar.present?
        ar.last.send(model_class.name.underscore.pluralize)
      else
        model_scope_without_nested
      end
    end
  end
  
  include Nested
  
end