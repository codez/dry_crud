# encoding: UTF-8

module DryCrud

  # Provides functionality to nest controllers/resources.
  # If a controller is nested, the parent classes and namespaces
  # may be defined as an array in the +nesting+ class attribute.
  #
  # For example, a cities controller, nested in country and a admin
  # namespace, may define this attribute as follows:
  #   self.nesting = :admin, Country
  module Nestable

    # Adds the :nesting class attribute and parent helper methods
    # to the including controller.
    def self.prepended(klass)
      klass.class_attribute :nesting

      klass.helper_method :parent, :parents
    end

    private

    # Returns the direct parent ActiveRecord of the current request, if any.
    def parent
      parents.reverse.find { |p| p.is_a?(ActiveRecord::Base) }
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
      model_ivar_set(clazz.find(params["#{clazz.name.underscore}_id"]))
    end

    # An array of objects used in url_for and related functions.
    def path_args(last)
      parents + [last]
    end

    # Uses the parent entry (if any) to constrain the model scope.
    def model_scope
      if parent.present?
        parent_scope
      else
        super
      end
    end

    # The model scope for the current parent resource.
    def parent_scope
      parent.send(model_class.name.underscore.pluralize)
    end

  end
end
