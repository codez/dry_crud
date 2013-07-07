# encoding: UTF-8

# Abstract controller providing a basic list action (#index).
# The action lists all entries of a certain model and provides functionality to
# search and sort this list.
# Furthermore, it remembers the last search and sort parameters after the
# user returns from a displayed or edited entry.
# The loaded model entries are available in the view as an instance variable
# named after the +model_class+ or by the helper method +entries+.
class ListController < ApplicationController

  helper_method :model_class, :models_label, :entries, :path_args

  delegate :model_class, :models_label, to: 'self.class'

  hide_action :model_class, :models_label, :inheritable_root_controller

  respond_to :html, :json

  ##############  ACTIONS  ############################################

  # List all entries of this model.
  #   GET /entries
  #   GET /entries.json
  def index(&block)
    respond_with(entries, &block)
  end

  private

  # Helper method to access the entries to be displayed in the current index
  # page in an uniform way.
  def entries
    get_model_ivar(true) || set_model_ivar(list_entries)
  end

  # The base relation used to filter the entries.
  # This method may be adapted as long it returns an
  # <tt>ActiveRecord::Relation</tt>.
  def list_entries
    model_scope
  end

  # The scope where model entries will be listed and created.
  # This is mainly used for nested models to provide the
  # required context.
  def model_scope
<% if Rails.version < '4.0' -%>
    model_class.scoped
<% else -%>
    model_class.all
<% end -%><%# > fixing rdoc -%>
  end

  # The path arguments to link to the given entry.
  # If the controller is nested, this provides the required context.
  def path_args(last)
    last
  end

  # Get the instance variable named after the +model_class+.
  # If the collection variable is required, pass true as the second argument.
  def get_model_ivar(plural = false)
    name = ivar_name(model_class)
    name = name.pluralize if plural
    instance_variable_get(:"@#{name}")
  end

  # Sets an instance variable with the underscored class name if the given
  # value. If the value is a collection, sets the plural name.
  def set_model_ivar(value)
    name = if value.respond_to?(:klass) # ActiveRecord::Relation
             ivar_name(value.klass).pluralize
           elsif value.respond_to?(:each) # Array
             ivar_name(value.first.class).pluralize
           else
             ivar_name(value.class)
           end
    instance_variable_set(:"@#{name}", value)
  end

  def ivar_name(klass)
    klass.model_name.param_key
  end

  class << self
    # The ActiveRecord class of the model.
    def model_class
      @model_class ||= controller_name.classify.constantize
    end

    # A human readable plural name of the model.
    def models_label(plural = true)
      opts = { count: (plural ? 3 : 1) }
      opts[:default] = model_class.model_name.human.titleize
      opts[:default] = opts[:default].pluralize if plural

      model_class.model_name.human(opts)
    end

  end

  # Provide +before_render+ callbacks.
  module Callbacks
    extend ActiveSupport::Concern

    included do
      extend ActiveModel::Callbacks

      alias_method_chain :render, :callbacks

      define_render_callbacks :index
    end

    # Helper method to run +before_render+ callbacks and render the action.
    # If a callback renders or redirects, the action is not rendered.
    def render_with_callbacks(*args, &block)
      options = _normalize_render(*args, &block)
      callback = "render_#{options[:template]}"

      run_callbacks(callback) if respond_to?(:"_#{callback}_callbacks", true)

      render_without_callbacks(*args, &block) unless performed?
    end

    private

    # Helper method the run the given block in between the before and after
    # callbacks of the given kinds.
    def with_callbacks(*kinds, &block)
      kinds.reverse.reduce(block) do |a, e|
        -> { run_callbacks(e, &a) }
      end.call
    end

    # Class methods for callbacks.
    module ClassMethods
      # Defines before callbacks for the render actions.
      def define_render_callbacks(*actions)
        args = actions.map { |a| :"render_#{a}" }
        args << { only: :before,
                  terminator: 'result == false || performed?' }
        define_model_callbacks(*args)
      end
    end
  end

  include Callbacks

  # The search functionality for the index table.
  # Define an array of searchable columns in your subclassing controllers
  # using the class attribute +search_columns+.
  module Search
    extend ActiveSupport::Concern

    included do
      class_attribute :search_columns
      self.search_columns = []

      helper_method :search_support?

      alias_method_chain :list_entries, :search
    end

    private

    # Enhance the list entries with an optional search criteria
    def list_entries_with_search
      list_entries_without_search.where(search_condition)
    end

    # Compose the search condition with a basic SQL OR query.
    def search_condition
      if search_support? && params[:q].present?
        col_clause = search_column_clause
        terms = params[:q].split(/\s+/).map { |t| "%#{t}%" }
        term_clause = terms.map { |t| "(#{col_clause})" }.join(' AND ')

        term_params = terms.map { |t| [t] * search_columns.size }.flatten
        ["(#{term_clause})", *term_params]
      end
    end

    # SQL where clause with all search colums or'ed.
    def search_column_clause
      search_columns.map do |f|
        if f.to_s.include?('.')
          "#{f} LIKE ?"
        else
          "#{model_class.table_name}.#{f} LIKE ?"
        end
      end.join(' OR ')
    end

    # Returns true if this controller has searchable columns.
    def search_support?
      search_columns.present?
    end

  end

  include Search

  # Sort functionality for the index table.
  # Define a default sort expression that is always appended to the
  # current sort params with the class attribute +default_sort+.
  module Sort
    extend ActiveSupport::Concern

    included do
      class_attribute :sort_mappings_with_indifferent_access
      self.sort_mappings = {}

      class_attribute :default_sort

      helper_method :sortable?

      alias_method_chain :list_entries, :sort
    end

    # Class methods for sorting.
    module ClassMethods
      # Define a map of (virtual) attributes to SQL order expressions.
      # May be used for sorting table columns that do not appear directly
      # in the database table. E.g., map city_id: 'cities.name' to
      # sort the displayed city names.
      def sort_mappings=(hash)
        self.sort_mappings_with_indifferent_access =
          hash.with_indifferent_access
      end
    end

    private

    # Enhance the list entries with an optional sort order.
    def list_entries_with_sort
      clause = []
      clause << sort_expression if sortable?(params[:sort])
      clause << default_sort

      list_entries_without_sort.order(clause.compact.join(', '))
    end

    # Return the sort expression to be used in the list query.
    def sort_expression
      col = sort_mappings_with_indifferent_access[params[:sort]] ||
            "#{model_class.table_name}.#{params[:sort]}"
      "#{col} #{sort_dir}"
    end

    # The sort direction, either 'asc' or 'desc'.
    def sort_dir
      params[:sort_dir] == 'desc' ? 'DESC' : 'ASC'
    end

    # Returns true if the passed attribute is sortable.
    def sortable?(attr)
      attr.present? && (
      model_class.column_names.include?(attr.to_s) ||
      sort_mappings_with_indifferent_access.include?(attr))
    end
  end

  include Sort

  # Remembers certain params of the index action in order to return
  # to the same list after an entry was viewed or edited.
  # If the index is called with a param :returning, the remembered params
  # will be re-used to present the user the same list as she left it.
  # Define a list of param keys that should be remembered for the list action
  # with the class attribute +remember_params+.
  module Memory
    extend ActiveSupport::Concern

    included do
      class_attribute :remember_params
      self.remember_params = [:q, :sort, :sort_dir, :page]

      before_filter :handle_remember_params, only: [:index]
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
        remember_params.each { |p| params[p] ||= remembered[p] }
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

  # Provides functionality to nest controllers/resources.
  # If a controller is nested, the parent classes and namespaces
  # may be defined as an array in the +nesting+ class attribute.
  # For example, a cities controller, nested in country and a admin
  # namespace, may define this attribute as follows:
  #   self.nesting = :admin, Country
  module Nesting
    extend ActiveSupport::Concern

    # Adds the :nesting class attribute and parent helper methods
    # to the including controller.
    included do
      class_attribute :nesting

      helper_method :parent, :parents

      alias_method_chain :model_scope, :nesting
      alias_method_chain :path_args, :nesting
    end

    private

    # Returns the direct parent ActiveRecord of the current request, if any.
    def parent
      parents.select { |p| p.is_a?(ActiveRecord::Base) }.last
    end

    # Returns the parent entries of the current request, if any.
    # These are ActiveRecords or namespace symbols, corresponding
    # to the defined nesting attribute.
    def parents
      @parents ||= Array(nesting).map do |p|
        if p.is_a?(Class) && p < ActiveRecord::Base
          parent_entry(p)
        else
          p
        end
      end
    end

    # Loads the parent entry for the given ActiveRecord class.
    # By default, performs a find with the class_name_id param.
    def parent_entry(clazz)
      set_model_ivar(clazz.find(params["#{clazz.name.underscore}_id"]))
    end

    # An array of objects used in url_for and related functions.
    def path_args_with_nesting(last)
      parents + [last]
    end

    # Uses the parent entry (if any) to constrain the model scope.
    def model_scope_with_nesting
      if parent.present?
        parent_scope
      else
        model_scope_without_nesting
      end
    end

    # The model scope for the current parent resource.
    def parent_scope
      parent.send(model_class.name.underscore.pluralize)
    end
  end

  include Nesting

end
