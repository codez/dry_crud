require 'test_helper'
require 'crud_test_model'
require 'custom_assertions'

class ListHelperTest < ActionView::TestCase
  
  REGEXP_ROWS = /<tr.+?<\/tr>/m
  REGEXP_HEADERS = /<th.+?<\/th>/m
  REGEXP_SORT_HEADERS = /<th><a .*?sort_dir=asc.*?>.*?<\/a><\/th>/m
  
  include StandardHelper
  include CrudTestHelper
  include CustomAssertions
  
  setup :reset_db, :setup_db, :create_test_data
  teardown :reset_db
  
  test "standard list table" do
    @entries = CrudTestModel.all
    
    t = with_test_routing do 
      list_table
    end
    
    assert_count 7, REGEXP_ROWS, t
    assert_count 11, REGEXP_SORT_HEADERS, t
  end
  
  test "custom list table with attributes" do
    @entries = CrudTestModel.all
    
    t = with_test_routing do
      list_table :name, :children, :companion_id
    end
        
    assert_count 7, REGEXP_ROWS, t
    assert_count 3, REGEXP_SORT_HEADERS, t
  end
    
  test "custom list table with block" do
    @entries = CrudTestModel.all
    
    t = with_test_routing do
      list_table do |t|
        t.attrs :name, :children, :companion_id
        t.col("head") {|e| content_tag :span, e.income.to_s }
      end
    end
    
    assert_count 7, REGEXP_ROWS, t
    assert_count 4, REGEXP_HEADERS, t
    assert_count 0, REGEXP_SORT_HEADERS, t
    assert_count 6, /<span>.+?<\/span>/, t
  end
  
  test "custom list table with attributes and block" do
    @entries = CrudTestModel.all
    
    t = with_test_routing do
      list_table :name, :children, :companion_id do |t|
        t.col("head") {|e| content_tag :span, e.income.to_s }
      end
    end
    
    assert_count 7, REGEXP_ROWS, t
    assert_count 3, REGEXP_SORT_HEADERS, t
    assert_count 4, REGEXP_HEADERS, t
    assert_count 6, /<span>.+?<\/span>/, t
  end
    
  test "standard list table with ascending sort params" do
    def params
      {:sort => 'children', :sort_dir => 'asc'}
    end
  
    @entries = CrudTestModel.all
    
    t = with_test_routing do 
      list_table
    end
    
    assert_count 7, REGEXP_ROWS, t
    assert_count 10, REGEXP_SORT_HEADERS, t
    assert_count 1, /<th><a .*?sort_dir=desc.*?>Children<\/a> &darr;<\/th>/, t
  end
  
  test "standard list table with descending sort params" do
    def params
      {:sort => 'children', :sort_dir => 'desc'}
    end
  
    @entries = CrudTestModel.all
    
    t = with_test_routing do 
      list_table
    end
    
    assert_count 7, REGEXP_ROWS, t
    assert_count 10, REGEXP_SORT_HEADERS, t
    assert_count 1, /<th><a .*?sort_dir=asc.*?>Children<\/a> &uarr;<\/th>/, t
  end
    
  test "list table with custom column sort params" do
    def params
      {:sort => 'chatty', :sort_dir => 'asc'}
    end
  
    @entries = CrudTestModel.all
    
    t = with_test_routing do 
      list_table :name, :children, :chatty
    end
    
    assert_count 7, REGEXP_ROWS, t
    assert_count 2, REGEXP_SORT_HEADERS, t
    assert_count 1, /<th><a .*?sort_dir=desc.*?>Chatty<\/a> &darr;<\/th>/, t
  end
  
  test "default attributes do not include id" do 
    assert_equal [:name, :whatever, :children, :companion_id, :rating, :income, 
                  :birthdate, :human, :remarks, :created_at, :updated_at], default_attrs
  end
  
  # Controller helper methods for the tests
  
  def model_class
    CrudTestModel
  end
  
  def params
  	{}
  end
  
  def sortable?(attr)
  	true
  end

    
end
