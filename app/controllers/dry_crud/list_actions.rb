# encoding: UTF-8

module DryCrud

  # Provides the index action to fetch a list of #entries for the current
  # model class.
  module ListActions
    extend ActiveSupport::Concern

    included do
      helper_method :entries
    end

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
    # Calls the #list scope if it is defined on the model class.
    #
    # This method may be adapted as long it returns an
    # <tt>ActiveRecord::Relation</tt>.
    # Some of the modules included extend this method.
    def list_entries
      model_class.respond_to?(:list) ? model_scope.list : model_scope
    end

  end
end
