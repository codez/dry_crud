require 'test_helper'
require 'support/custom_assertions'
require 'support/crud_test_model'

class TableHelperTest < ActionView::TestCase

  include UtilityHelper
  include FormatHelper
  include I18nHelper
  include CustomAssertions
  include CrudTestHelper

  setup :reset_db, :setup_db, :create_test_data
  teardown :reset_db

  attr_reader :entries

  def format_size(obj)
    "#{f(obj.size)} items"
  end

  def format_string_size(obj)
    "#{f(obj.size)} chars"
  end

  test "empty table should render message" do
    result = plain_table([]) { }
    assert result.html_safe?
    assert_dom_equal "<div class='table'>No entries found.</div>", result
  end

  test "non empty table should render table" do
    result = plain_table(['foo', 'bar']) {|t| t.attrs :size, :upcase }
    assert result.html_safe?
    assert_match(/^\<table.*\<\/table\>$/, result)
  end

  test "table with attrs" do
    expected = Crud::TableBuilder.table(['foo', 'bar'], self, :class => 'table') { |t| t.attrs :size, :upcase }
    actual = plain_table(['foo', 'bar'], :size, :upcase)
    assert actual.html_safe?
    assert_equal expected, actual
  end

  test "standard list table" do
    @entries = CrudTestModel.all

    t = with_test_routing do
      list_table
    end

    assert_count 7, REGEXP_ROWS, t
    assert_count 14, REGEXP_SORT_HEADERS, t
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
    assert_count 13, REGEXP_SORT_HEADERS, t
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
    assert_count 13, REGEXP_SORT_HEADERS, t
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

  test "standard crud table" do
    @entries = CrudTestModel.all

    t = with_test_routing do
      crud_table
    end

    assert_count 7, REGEXP_ROWS, t
    assert_count 14, REGEXP_SORT_HEADERS, t
    assert_count 12, REGEXP_ACTION_CELL, t      # edit, delete links
  end

  test "custom crud table with attributes" do
    @entries = CrudTestModel.all

    t = with_test_routing do
      crud_table :name, :children, :companion_id
    end

    assert_count 7, REGEXP_ROWS, t
    assert_count 3, REGEXP_SORT_HEADERS, t
    assert_count 12, REGEXP_ACTION_CELL, t      # edit, delete links
  end

  test "custom crud table with block" do
    @entries = CrudTestModel.all

    t = with_test_routing do
      crud_table do |t|
        t.attrs :name, :children, :companion_id
        t.col("head") {|e| content_tag :span, e.income.to_s }
      end
    end

    assert_count 7, REGEXP_ROWS, t
    assert_count 6, REGEXP_HEADERS, t
    assert_count 6, /<span>.+?<\/span>/m, t
    assert_count 12, REGEXP_ACTION_CELL, t      # edit, delete links
  end

  test "custom crud table with attributes and block" do
    @entries = CrudTestModel.all

    t = with_test_routing do
      crud_table :name, :children, :companion_id do |t|
        t.col("head") {|e| content_tag :span, e.income.to_s }
      end
    end

    assert_count 7, REGEXP_ROWS, t
    assert_count 3, REGEXP_SORT_HEADERS, t
    assert_count 6, REGEXP_HEADERS, t
    assert_count 6, /<span>.+?<\/span>/m, t
    assert_count 12, REGEXP_ACTION_CELL, t      # edit, delete links
  end

  def entry
    @entry ||= CrudTestModel.first
  end

end
