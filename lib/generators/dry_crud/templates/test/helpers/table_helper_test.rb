require 'test_helper'
require 'support/custom_assertions'
require 'support/crud_test_model'

# Test TableHelper
class TableHelperTest < ActionView::TestCase

  include UtilityHelper
  include FormatHelper
  include I18nHelper
  include CustomAssertions
  include CrudTestHelper

  attr_accessor :params

  setup :reset_db, :setup_db, :create_test_data, :empty_params
  teardown :reset_db

  attr_reader :entries

  def format_size(obj)
    "#{f(obj.size)} items"
  end

  def format_string_size(obj)
    "#{f(obj.size)} chars"
  end

  def empty_params
    @params = {}
  end

  test 'empty table renders message' do
    result = plain_table_or_message([])
    assert result.html_safe?
    assert_match(/<div class=["']table["']>.*<\/div>/, result)
  end

  test 'non empty table renders table' do
    result = plain_table_or_message(%w[foo bar]) do |t|
      t.attrs :size, :upcase
    end
    assert result.html_safe?
    assert_match(/^<table.*<\/table>$/, result)
  end

  test 'table with attrs' do
    expected = DryCrud::Table::Builder.table(
      %w[foo bar], self,
      class: 'table table-striped table-hover'
    ) do |t|
      t.attrs :size, :upcase
    end
    actual = plain_table(%w[foo bar], :size, :upcase)
    assert actual.html_safe?
    assert_equal expected, actual
  end

  test 'standard list table' do
    @entries = CrudTestModel.all

    table = with_test_routing do
      list_table
    end

    assert_count 7, REGEXP_ROWS, table
    assert_count 14, REGEXP_SORT_HEADERS, table
  end

  test 'custom list table with attributes' do
    @entries = CrudTestModel.all

    table = with_test_routing do
      list_table :name, :children, :companion_id
    end

    assert_count 7, REGEXP_ROWS, table
    assert_count 3, REGEXP_SORT_HEADERS, table
  end

  test 'custom list table with block' do
    @entries = CrudTestModel.all

    table = with_test_routing do
      list_table do |t|
        t.attrs :name, :children, :companion_id
        t.col('head') { |e| tag.span(e.income.to_s) }
      end
    end

    assert_count 7, REGEXP_ROWS, table
    assert_count 4, REGEXP_HEADERS, table
    assert_count 0, REGEXP_SORT_HEADERS, table
    assert_count 6, /<span>.+?<\/span>/, table
  end

  test 'custom list table with attributes and block' do
    @entries = CrudTestModel.all

    table = with_test_routing do
      list_table :name, :children, :companion_id do |t|
        t.col('head') { |e| tag.span(e.income.to_s) }
      end
    end

    assert_count 7, REGEXP_ROWS, table
    assert_count 3, REGEXP_SORT_HEADERS, table
    assert_count 4, REGEXP_HEADERS, table
    assert_count 6, /<span>.+?<\/span>/, table
  end

  test 'standard list table with ascending sort params' do
    @params = { sort: 'children', sort_dir: 'asc' }
    @entries = CrudTestModel.all

    table = with_test_routing do
      list_table
    end

    sort_header_desc = %r{<th><a .*?sort_dir=desc.*?>Children</a> &darr;</th>}
    assert_count 7, REGEXP_ROWS, table
    assert_count 13, REGEXP_SORT_HEADERS, table
    assert_count 1, sort_header_desc, table
  end

  test 'standard list table with descending sort params' do
    @params = { sort: 'children', sort_dir: 'desc' }
    @entries = CrudTestModel.all

    table = with_test_routing do
      list_table
    end

    sort_header_asc = %r{<th><a .*?sort_dir=asc.*?>Children</a> &uarr;</th>}
    assert_count 7, REGEXP_ROWS, table
    assert_count 13, REGEXP_SORT_HEADERS, table
    assert_count 1, sort_header_asc, table
  end

  test 'list table with custom column sort params' do
    @params = { sort: 'chatty', sort_dir: 'asc' }
    @entries = CrudTestModel.all

    table = with_test_routing do
      list_table :name, :children, :chatty
    end

    sort_header_desc = %r{<th><a .*?sort_dir=desc.*?>Chatty</a> &darr;</th>}
    assert_count 7, REGEXP_ROWS, table
    assert_count 2, REGEXP_SORT_HEADERS, table
    assert_count 1, sort_header_desc, table
  end

  test 'standard crud table' do
    @entries = CrudTestModel.all

    table = with_test_routing do
      crud_table
    end

    assert_count 7, REGEXP_ROWS, table
    assert_count 14, REGEXP_SORT_HEADERS, table
    assert_count 12, REGEXP_ACTION_CELL, table      # edit, delete links
  end

  test 'custom crud table with attributes' do
    @entries = CrudTestModel.all

    table = with_test_routing do
      crud_table :name, :children, :companion_id
    end

    assert_count 7, REGEXP_ROWS, table
    assert_count 3, REGEXP_SORT_HEADERS, table
    assert_count 12, REGEXP_ACTION_CELL, table      # edit, delete links
  end

  test 'custom crud table with block' do
    @entries = CrudTestModel.all

    table = with_test_routing do
      crud_table do |t|
        t.attrs :name, :children, :companion_id
        t.col('head') { |e| tag.span(e.income.to_s) }
      end
    end

    assert_count 7, REGEXP_ROWS, table
    assert_count 6, REGEXP_HEADERS, table
    assert_count 6, /<span>.+?<\/span>/m, table
    assert_count 12, REGEXP_ACTION_CELL, table      # edit, delete links
  end

  test 'custom crud table with attributes and block' do
    @entries = CrudTestModel.all

    table = with_test_routing do
      crud_table :name, :children, :companion_id do |t|
        t.col('head') { |e| tag.span(e.income.to_s) }
      end
    end

    assert_count 7, REGEXP_ROWS, table
    assert_count 3, REGEXP_SORT_HEADERS, table
    assert_count 6, REGEXP_HEADERS, table
    assert_count 6, /<span>.+?<\/span>/m, table
    assert_count 12, REGEXP_ACTION_CELL, table      # edit, delete links
  end

  def entry
    @entry ||= CrudTestModel.first
  end

end
