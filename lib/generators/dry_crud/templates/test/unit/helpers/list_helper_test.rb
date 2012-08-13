require 'test_helper'
require 'crud_test_model'
require 'custom_assertions'

class ListHelperTest < ActionView::TestCase

  include StandardHelper
  include CrudTestHelper
  include CustomAssertions

  attr_reader :entries

  setup :reset_db, :setup_db, :create_test_data
  teardown :reset_db

  test "standard list table" do
    @entries = CrudTestModel.all

    t = with_test_routing do
      list_table
    end

    assert_count 7, REGEXP_ROWS, t
    assert_count 13, REGEXP_SORT_HEADERS, t
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
    assert_count 12, REGEXP_SORT_HEADERS, t
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
    assert_count 12, REGEXP_SORT_HEADERS, t
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
                  :birthdate, :gets_up_at, :last_seen, :human, :remarks,
                  :created_at, :updated_at], default_attrs
  end

end
