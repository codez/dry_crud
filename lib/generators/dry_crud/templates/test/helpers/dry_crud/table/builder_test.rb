# encoding: UTF-8
require 'test_helper'

# Test DryCrud::Table::Builder
class DryCrud::Table::BuilderTest < ActionView::TestCase

  # set dummy helper class for ActionView::TestCase
  self.helper_class = UtilityHelper

  include FormatHelper

  attr_reader :table, :entries

  def setup
    @entries = %w(foo bahr)
    @table = DryCrud::Table::Builder.new(entries, self)
  end

  def format_size(obj)
    "#{obj.size} chars"
  end

  test 'html header' do
    table.attrs :upcase, :size

    dom = '<tr><th>Upcase</th><th>Size</th></tr>'

    assert_dom_equal dom, table.send(:html_header)
  end

  test 'single attr row' do
    table.attrs :upcase, :size

    dom = '<tr><td>FOO</td><td>3 chars</td></tr>'

    assert_dom_equal dom, table.send(:html_row, entries.first)
  end

  test 'custom row' do
    table.col('Header', class: 'hula') { |e| "Weights #{e.size} kg" }

    dom = '<tr><td class="hula">Weights 3 kg</td></tr>'

    assert_dom_equal dom, table.send(:html_row, entries.first)
  end

  test 'attr col output' do
    table.attrs :upcase
    col = table.cols.first

    assert_equal '<th>Upcase</th>', col.html_header
    assert_equal 'FOO', col.content('foo')
    assert_equal '<td>FOO</td>', col.html_cell('foo')
  end

  test 'attr col content with custom format_size method' do
    table.attrs :size
    col = table.cols.first

    assert_equal '4 chars', col.content('abcd')
  end

  test 'two x two table' do
    dom = <<-FIN
      <table>
      <thead>
      <tr><th>Upcase</th><th>Size</th></tr>
      </thead>
    <tbody>
      <tr><td>FOO</td><td>3 chars</td></tr>
      <tr><td>BAHR</td><td>4 chars</td></tr>
      </tbody>
      </table>
    FIN
    dom.gsub!(/[\n\t]/, '').gsub!(/\s{2,}/, '')

    table.attrs :upcase, :size

    assert_dom_equal dom, table.to_html
  end

  test 'table with before and after cells' do
    dom = <<-FIN
      <table>
      <thead>
      <tr><th class='left'>head</th><th>Upcase</th><th>Size</th><th></th></tr>
      </thead>
      <tbody>
      <tr>
        <td class='left'><a href='/'>foo</a></td>
        <td>FOO</td>
        <td>3 chars</td>
        <td>Never foo</td>
      </tr>
      <tr>
        <td class='left'><a href='/'>bahr</a></td>
        <td>BAHR</td>
        <td>4 chars</td>
        <td>Never bahr</td>
      </tr>
      </tbody>
      </table>
    FIN
    dom.gsub!(/[\n\t]/, '').gsub!(/\s{2,}/, '')

    table.col('head', class: 'left') { |e| link_to e, '/' }
    table.attrs :upcase, :size
    table.col { |e| "Never #{e}" }

    assert_dom_equal dom, table.to_html
  end

  test 'empty entries collection renders empty table' do
    dom = <<-FIN
      <table>
      <thead>
      <tr><th class='left'>head</th><th>Upcase</th><th>Size</th><th></th></tr>
      </thead>
      <tbody>
      </tbody>
      </table>
    FIN
    dom.gsub!(/[\n\t]/, '').gsub!(/\s{2,}/, '')

   table = DryCrud::Table::Builder.new([], self)
    table.col('head', class: 'left') { |e| link_to e, '/' }
    table.attrs :upcase, :size
    table.col { |e| "Never #{e}" }

    assert_dom_equal dom, table.to_html
  end

end
