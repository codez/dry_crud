# encoding: UTF-8

# Contains assertions for testing common crud controller use cases.
# See crud_controller_examples for use cases.
module CrudControllerTestHelper
  extend ActiveSupport::Concern

  # Performs a request based on the metadata of the action example under test.
  def perform_request
    m = RSpec.current_example.metadata
    example_params = respond_to?(:params) ? send(:params) : {}
    params = scope_params.dup
    params[:format] = m[:format] if m[:format]
    params[:id] = test_entry.id if m[:id]
    params.merge!(example_params)
    if m[:method] == :get && m[:format] == :js
      get m[:action], params: params, xhr: true
    else
      send(m[:method], m[:action], params: params)
    end
  end

  # If a combine key is given in metadata, only the first request for all
  # examples with the same key will be performed.
  def perform_combined_request
    stack = RSpec.current_example.metadata[:combine]
    if stack
      @@current_stack ||= nil
      if stack == @@current_stack &&
         described_class == @@current_controller.class
        restore_request
      else
        perform_request
        @@current_stack = stack
        remember_request
      end
    else
      perform_request
    end
  end

  def remember_request
    @@current_response = @response
    @@current_request = @request
    @@current_controller = @controller
    @@current_templates = @_templates || @templates

    # treat in-memory entry as committed in order to
    # avoid rollback of internal state.
    entry.committed! if entry
  end

  def restore_request
    @response = @@current_response
    @_templates = @templates = @@current_templates
    @controller = @@current_controller
    @request = @@current_request
  end

  def ivar(name)
    controller.instance_variable_get("@#{name}")
  end

  # The params defining the nesting of the test entry.
  def scope_params
    params = {}
    # for nested controllers, add parent ids to each request
    Array(controller.nesting).reverse.reduce(test_entry) do |parent, p|
      if p.is_a?(Class) && p < ActiveRecord::Base
        assoc = p.name.underscore
        params["#{assoc}_id"] = parent.send(:"#{assoc}_id")
        parent.send(assoc)
      else
        parent
      end
    end
    params
  end

  # Helper methods to describe contexts.
  module ClassMethods

    # Describe a certain action and provide some usefull metadata.
    # Tests whether this action is configured to be skipped.
    def describe_action(method, action, metadata = {}, &block)
      action_defined = described_class.instance_methods
                                      .map(&:to_s)
                                      .include?(action.to_s)
      describe("#{method.to_s.upcase} #{action}",
               { if: action_defined,
                 method: method,
                 action: action }.merge(metadata),
               &block)
    end

    # Is the current context part of the skip list.
    def skip?(options, *contexts)
      options ||= {}
      contexts = Array(contexts).flatten
      skips = Array(options[:skip])
      skips = [skips] if skips.blank? || !skips.first.is_a?(Array)

      skips.flatten.present? &&
        skips.any? { |skip| skip == contexts.take(skip.size) }
    end

    # Test the response status, default 200.
    def it_is_expected_to_respond(status = 200)
      it { expect(response.status).to eq(status) }
    end

    # Test that a json response is rendered.
    def it_is_expected_to_render_json
      it { expect(response.body).to start_with('{') }
    end

    # Test that test_entry_attrs are set on entry.
    def it_is_expected_to_set_attrs(action = nil)
      it 'sets params as entry attributes' do
        attrs = send("#{action}_entry_attrs")
        actual = {}
        attrs.keys.each do |key|
          actual[key] = entry.attributes[key.to_s]
        end
        expect(actual).to eq(attrs)
      end
    end

    # Test that the response redirects to the index action.
    def it_is_expected_to_redirect_to_index
      it do
        is_expected.to redirect_to scope_params.merge(action: 'index',
                                                      id: nil,
                                                      returning: true)
      end
    end

    # Test that the response redirects to the show action of the current entry.
    def it_is_expected_to_redirect_to_show
      it do
        is_expected.to redirect_to scope_params.merge(action: 'show',
                                                      id: entry.id)
      end
    end

    # Test that the given flash type is present.
    def it_is_expected_to_have_flash(type, message = nil)
      it "flash(#{type}) is set" do
        expect(flash[type]).to(message ? match(message) : be_present)
      end
    end

    # Test that not flash of the given type is present.
    def it_is_expected_to_not_have_flash(type)
      it "flash(#{type}) is nil" do
        expect(flash[type]).to be_blank
      end
    end

    # Test that the current entry is persistend and valid, or not.
    def it_is_expected_to_persist_entry(bool = true)
      context 'entry' do
        subject { entry }

        if bool
          it { is_expected.not_to be_new_record }
          it { is_expected.to be_valid }
        else
          it { is_expected.to be_new_record }
        end
      end
    end
  end

end
