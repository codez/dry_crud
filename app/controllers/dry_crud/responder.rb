# encoding: UTF-8

module DryCrud
  # Custom Responder that handles the controller's +path_args+.
  # An additional :success option is used to handle action callback
  # chain halts.
  class Responder < ActionController::Responder

    def initialize(controller, resources, options = {})
      super(controller, with_path_args(resources, controller), options)
    end

    private

    # Check whether the resource has errors. Additionally checks the :success
    # option.
    def has_errors?
      options[:success] == false || super
    end

    # Wraps the resources with the path_args for correct nesting.
    def with_path_args(resources, controller)
      if resources.size == 1
        Array(controller.send(:path_args, resources.first))
      else
        resources
      end
    end

  end
end
