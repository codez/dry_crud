# encoding: UTF-8

module DryCrud
  # Connects the including controller to the model whose name corrsponds to
  # the controller's name.
  #
  # The two main methods are +model_class+ and +model_scope+.
  # Additional helper methods store and retrieve values in instance variables
  # named after their class.
  module GenericModel
    extend ActiveSupport::Concern

    included do
      helper_method :model_class, :models_label, :path_args

    private

      delegate :model_class, :models_label, :model_identifier, to: 'self.class'
    end

    private

  # The scope where model entries will be listed and created.
  # This is mainly used for nested models to provide the
  # required context.
  def model_scope
    if Rails.version < '4.0'
      model_class.scoped
    else
      model_class.all
    end
  end

    # The path arguments to link to the given model entry.
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

  # Class methods from GenericModel.
  module ClassMethods
    # The ActiveRecord class of the model.
    def model_class
      @model_class ||= controller_name.classify.constantize
    end

      # The identifier of the model used for form parameters.
      # I.e., the symbol of the underscored model name.
      def model_identifier
        @model_identifier ||= model_class.model_name.param_key
      end

    # A human readable plural name of the model.
    def models_label(plural = true)
      opts = { count: (plural ? 3 : 1) }
      opts[:default] = model_class.model_name.human.titleize
      opts[:default] = opts[:default].pluralize if plural

      model_class.model_name.human(opts)
    end
  end

  end
end
