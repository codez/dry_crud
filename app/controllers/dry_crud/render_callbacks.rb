# encoding: UTF-8

module DryCrud
  # Provide +before_render+ callbacks.
  module RenderCallbacks
    extend ActiveSupport::Concern

    included do
      extend ActiveModel::Callbacks

      alias_method_chain :render, :callbacks
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
end
