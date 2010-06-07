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
    
  test "input_field dispatches text attr to text_area" do
    assert_equal form.text_area(:remarks), form.input_field(:remarks)
  end
  
  test "input_field dispatches integer attr to integer_field" do
    assert_equal form.integer_field(:children), form.input_field(:children)
  end
  
  test "input_field dispatches boolean attr to boolean_field" do
    assert_equal form.boolean_field(:human), form.input_field(:human)
  end  
  
  test "input_field dispatches date attr to date_field" do
    assert_equal form.date_field(:birthdate), form.input_field(:birthdate)
  end
    
  test "input_field dispatches belongs_to attr to select field" do
    assert_equal form.belongs_to_field(:companion_id), form.input_field(:companion_id)
  end
  
  test "belongs_to_field has all options by default" do
    f = form.belongs_to_field(:companion_id)
    assert_match /(\<option .*?){7}/m, f
    assert_no_match /(\<option .*?){8}/m, f
  end
    
  test "belongs_to_field with :list option" do
    list = CrudTestModel.all
    f = form.belongs_to_field(:companion_id, :list => [list.first, list.second])
    assert_match /(\<option .*?){3}/m, f
    assert_no_match /(\<option .*?){4}/m, f
  end
  
  test "belongs_to_field with instance variable" do
    list = CrudTestModel.all
    @companions = [list.first, list.second]
    f = form.belongs_to_field(:companion_id)
    assert_match /(\<option .*?){3}/m, f
    assert_no_match /(\<option .*?){4}/m, f
  end
  
  test "string_field sets maxlength attribute if limit" do
    assert_match /maxlength="50"/, form.string_field(:name)
  end
  
  test "labeld_text_field create label" do
    assert_match /label for.+input/m, form.labeled_string_field(:name)
  end
  
  
end