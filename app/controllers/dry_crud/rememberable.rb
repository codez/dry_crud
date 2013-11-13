# encoding: UTF-8

module DryCrud
  # Remembers certain params of the index action in order to return
  # to the same list after an entry was viewed or edited.
  # If the index is called with a param :returning, the remembered params
  # will be re-used to present the user the same list as she left it.
  #
  # Define a list of param keys that should be remembered for the list action
  # with the class attribute +remember_params+.
  #
  # The params are stored separately for each different +remember_key+, which
  # defaults to the current request's path.
  module Rememberable
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
end
