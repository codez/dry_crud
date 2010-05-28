require 'test_helper'
require 'crud_test_model'

class StandardFormBuilderTest < ActionView::TestCase
  
  include CrudTestHelper
  
  # set dummy helper class for ActionView::TestCase
  self.helper_class = StandardHelper
  
  attr_reader :form, :entry
  
  setup :reset_db, :setup_db, :create_test_data, :create_form
  teardown :reset_db
  
  def create_form
    @entry = CrudTestModel.first
    @form = StandardFormBuilder.new(:entry, @entry, self, {}, lambda {|form| form })
  end
  
  test "input_field dispatches string attr to string_field" do
    assert_equal form.string_field(:name), form.input_field(:name)
  end
  
  test "input_field dispatches integer attr to integer_field" do
    assert_equal form.integer_field(:children), form.input_field(:children)
  end
  
  test "input_field dispatches boolean attr to boolean_field" do
    assert_equal form.boolean_field(:human), form.input_field(:human)
  end
  
  test "string_field sets maxlength attribute" do
    assert_match /maxlength="50"/, form.string_field(:name)
  end
  
  
end