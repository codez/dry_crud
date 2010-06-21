require 'test_helper'
require 'crud_test_model'

class CrudHelperTest < ActionView::TestCase
  
  include StandardHelper
  include CrudTestHelper
  
  setup :reset_db, :setup_db, :create_test_data
  teardown :reset_db
  
  def model_class
    CrudTestModel
  end
  
  test "standard crud table" do
    @entries = CrudTestModel.all
    
    t = with_test_routing do 
      crud_table
    end
    
    assert_match /(<tr.+?<\/tr>){7}/m, t
    assert_match /(<th.+?<\/th>){14}/m, t
    assert_match /(<a href.+?<\/a>.*?){18}/m, t
  end
    
  test "custom crud table" do
    @entries = CrudTestModel.all
    
    t = with_test_routing do
      crud_table do |t|
        t.attrs :name, :children, :companion_id
        t.col("head") {|e| content_tag :span, e.income.to_s }
      end
    end
    
    assert_match /(<tr.+?<\/tr>){7}/m, t
    assert_match /(<th.+?<\/th>){4}/m, t
    assert_match /(<span>.+?<\/span>.*?){6}/m, t
    assert_no_match /(<a href.+?<\/a>.*?)/m, t
  end
  
  test "crud form" do
    @entry = CrudTestModel.first
    f = with_test_routing do
      capture { crud_form }
    end
    
    assert_match /form .*?action="\/crud_test_models\/#{@entry.id}"/, f
    assert_match /input .*?name="crud_test_model\[name\]" .*?type="text"/, f
    assert_match /input .*?name="crud_test_model\[whatever\]" .*?type="text"/, f
    assert_match /input .*?name="crud_test_model\[children\]" .*?type="text"/, f
    assert_match /input .*?name="crud_test_model\[rating\]" .*?type="text"/, f
    assert_match /input .*?name="crud_test_model\[income\]" .*?type="text"/, f
    assert_match /select .*?name="crud_test_model\[birthdate\(1i\)\]"/, f
    assert_match /input .*?name="crud_test_model\[human\]" .*?type="checkbox"/, f
    assert_match /select .*?name="crud_test_model\[companion_id\]"/, f
    assert_match /textarea .*?name="crud_test_model\[remarks\]"/, f
  end
  
  test "default attributes do not include id" do 
    assert_equal [:name, :whatever, :children, :companion_id, :rating, :income, 
                  :birthdate, :human, :remarks, :created_at, :updated_at], default_attrs
  end
    
  private
  
  def with_test_routing
    with_routing do |set|
      set.draw {|map| map.resources :crud_test_models }
      yield
    end
  end
end
