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
    assert form.string_field(:name).html_safe?
  end
    
  test "input_field dispatches password attr to password_field" do
    assert_equal form.password_field(:password), form.input_field(:password)
    assert form.password_field(:name).html_safe?
  end
  
  test "input_field dispatches text attr to text_area" do
    assert_equal form.text_area(:remarks), form.input_field(:remarks)
    assert form.text_area(:remarks).html_safe?
  end
  
  test "input_field dispatches integer attr to integer_field" do
    assert_equal form.integer_field(:children), form.input_field(:children)
    assert form.integer_field(:children).html_safe?
  end
  
  test "input_field dispatches boolean attr to boolean_field" do
    assert_equal form.boolean_field(:human), form.input_field(:human)
    assert form.boolean_field(:human).html_safe?
  end  
  
  test "input_field dispatches date attr to date_field" do
    assert_equal form.date_field(:birthdate), form.input_field(:birthdate)
    assert form.date_field(:birthdate).html_safe?
  end
    
  test "input_field dispatches belongs_to attr to select field" do
    assert_equal form.belongs_to_field(:companion_id), form.input_field(:companion_id)
    assert form.belongs_to_field(:companion_id).html_safe?
  end
  
  test "input_fields concats multiple fields" do
  	result = form.labeled_input_fields(:name, :remarks, :children)
  	assert result.html_safe?
  	assert result.include?(form.input_field(:name))
  	assert result.include?(form.input_field(:remarks))
  	assert result.include?(form.input_field(:children))
  end
  
  test "labeld_input_field adds required mark" do
  	result = form.labeled_input_field(:name)
  	assert result.include?(StandardFormBuilder::REQUIRED_MARK)
  	result = form.labeled_input_field(:remarks)
  	assert !result.include?(StandardFormBuilder::REQUIRED_MARK)
  end
  
  test "belongs_to_field has all options by default" do
    f = form.belongs_to_field(:companion_id)
    assert_equal 7, f.scan('</option>').size
  end
    
  test "belongs_to_field with :list option" do
    list = CrudTestModel.all
    f = form.belongs_to_field(:companion_id, :list => [list.first, list.second])
    assert_equal 3, f.scan('</option>').size
  end
  
  test "belongs_to_field with instance variable" do
    list = CrudTestModel.all
    @companions = [list.first, list.second]
    f = form.belongs_to_field(:companion_id)
    assert_equal 3, f.scan('</option>').size
  end
  
  test "belongs_to_field with empty list" do
    @companions = []
    f = form.belongs_to_field(:companion_id)
    assert_match /none available/m, f
    assert_equal 0, f.scan('</option>').size
  end
  
  test "string_field sets maxlength attribute if limit" do
    assert_match /maxlength="50"/, form.string_field(:name)
  end
  
  test "label creates captionized label" do
  	assert_match /label for.+Gugus dada/, form.label(:gugus_dada)
  	assert form.label(:gugus_dada).html_safe?
  end
  
  test "classic label still works" do
  	assert_match /label for.+hoho/, form.label(:gugus_dada, "hoho")
  	assert form.label(:gugus_dada, "hoho").html_safe?
  end
  
  test "labeled_text_field create label" do
    assert_match /label for.+input/m, form.labeled_string_field(:name)
    assert form.labeled_string_field(:name).html_safe?
  end
  
  test "labeled field creates label" do
  	result = form.labeled("gugus", "<input type='text' name='gugus' />")
  	assert result.html_safe?
  	assert_match /label for.+input/m, result
  end
  
  test "required mark is shown" do
    assert_equal StandardFormBuilder::REQUIRED_MARK, form.required_mark(:name)
    assert_equal "", form.required_mark(:rating)
    assert_equal "", form.required_mark(:anything)
  end
  
  test "method missing still works" do
    assert_raise(NoMethodError) do
      form.blabla
    end
  end    

  test "respond to still works" do
    assert !form.respond_to?(:blalba)
    assert form.respond_to?(:text_field)
    assert form.respond_to?(:labeled_text_field)
  end
end