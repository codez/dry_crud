# encoding: UTF-8

# Contains assertions for testing common crud controller use cases.
# See crud_controller_examples for use cases.
module CrudControllerTestHelper
  extend ActiveSupport::Concern

  # Performs a request based on the metadata of the action example under test.
  def perform_request
    m = example.metadata
    example_params = respond_to?(:params) ? send(:params) : {}
    params = scope_params.merge(format: m[:format])
    params.merge!(id: test_entry.id) if m[:id]
    params.merge!(example_params)
    send(m[:method], m[:action], params)
  end

  # If a combine key is given in metadata, only the first request for all
  # examples with the same key will be performed.
  def perform_combined_request
    stack = example.metadata[:combine]
    if stack
      @@current_stack ||= nil
      if stack == @@current_stack &&
         described_class == @@current_controller.class
        @response = @@current_response
        @_templates = @templates = @@current_templates
        @controller = @@current_controller
        @request = @@current_request
      else
        perform_request

        @@current_stack = stack
        @@current_response = @response
        @@current_request = @request
        @@current_controller = @controller
        @@current_templates = @_templates || @templates
      end
    else
      perform_request
    end
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
                         .map(&:to_s).include?(action.to_s)
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
    def it_should_respond(status = 200)
      its(:status) { should == status }
    end

    # Test that entries are assigned.
    def it_should_assign_entries
      it 'should assign entries' do
        entries.should be_present
      end
    end

    # Test that entry is assigned.
    def it_should_assign_entry
      it 'should assign entry' do
        entry.should == test_entry
      end
    end

    # Test that the given template or the main template of the action under
    # test is rendered.
    def it_should_render(template = nil)
      it { should render_template(template || example.metadata[:action]) }
    end

    # Test that test_entry_attrs are set on entry.
    def it_should_set_attrs(action = nil)
      it 'should set params as entry attributes' do
        attrs = send("#{action}_entry_attrs")
        actual = {}
        attrs.keys.each do |key|
          actual[key] = entry.attributes[key.to_s]
        end
        actual.should == attrs
      end
    end

    # Test that the response redirects to the index action.
    def it_should_redirect_to_index
      it do
        should redirect_to scope_params.merge(action: 'index',
                                              returning: true)
      end
    end

    # Test that the response redirects to the show action of the current entry.
    def it_should_redirect_to_show
      it do
        should redirect_to scope_params.merge(action: 'show',
                                              id: entry.id)
      end
    end

    # Test that the given flash type is present.
    def it_should_have_flash(type, message = nil)
      it "flash(#{type}) is set" do
        flash[type].should(message ? match(message) : be_present)
      end
    end

    # Test that not flash of the given type is present.
    def it_should_not_have_flash(type)
      it "flash(#{type}) is nil" do
        flash[type].should be_blank
      end
    end

    # Test that the current entry is persistend and valid, or not.
    def it_should_persist_entry(bool = true)
      context 'entry' do
        subject { entry }

        if bool
          it { should_not be_new_record }
          it { should be_valid }
        else
          it { should be_new_record }
        end
      end
    end
  end

end
