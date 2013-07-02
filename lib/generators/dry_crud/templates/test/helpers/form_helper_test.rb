require 'test_helper'
require 'support/crud_test_model'

class FormHelperTest < ActionView::TestCase

  include UtilityHelper
  include FormatHelper
  include I18nHelper
  include CrudTestHelper

  setup :reset_db, :setup_db, :create_test_data
  teardown :reset_db

  test "plain form for existing entry" do
    e = crud_test_models('AAAAA')
    f = with_test_routing do
      f = capture { plain_form(e, :html => {:class => 'special'}) {|f| f.labeled_input_fields :name, :birthdate } }
    end

    assert_match /form .*?action="\/crud_test_models\/#{e.id}" .*?class="special form-horizontal" .*?method="post"/, f
    assert_match /input .*?name="_method" .*?type="hidden" .*?value="(patch|put)"/, f
    assert_match /input .*?name="crud_test_model\[name\]" .*?type="text" .*?value="AAAAA"/, f
  end

  test "standard form" do
    e = crud_test_models('AAAAA')
    f = with_test_routing do
      f = capture { standard_form(e, :name, :children, :birthdate, :human, :cancel_url => '/somewhere', :html => {:class => 'special'}) }
    end

    assert_match /form .*?action="\/crud_test_models\/#{e.id}" .*?class="special form-horizontal" .*?method="post"/, f
    assert_match /input .*?name="_method" .*?type="hidden" .*?value="(patch|put)"/, f
    assert_match /input .*?name="crud_test_model\[name\]" .*?type="text" .*?value="AAAAA"/, f
    assert_match /select .*?name="crud_test_model\[birthdate\(1i\)\]"/, f
    assert_match /input .*?name="crud_test_model\[children\]" .*?type="number" .*?value=\"9\"/, f
    assert_match /input .*?name="crud_test_model\[human\]" .*?type="checkbox"/, f
    assert_match /button .*?type="submit">Save<\/button>/, f
    assert_match /a .*href="\/somewhere".*>Cancel<\/a>/, f
  end

  test "standard form with errors" do
    e = crud_test_models('AAAAA')
    e.name = nil
    assert !e.valid?

    f = with_test_routing do
      f = capture { standard_form(e) {|f| f.labeled_input_fields(:name, :birthdate) } }
    end

    assert_match /form .*?action="\/crud_test_models\/#{e.id}" .*?method="post"/, f
    assert_match /input .*?name="_method" .*?type="hidden" .*?value="(patch|put)"/, f
    assert_match /div[^>]* id='error_explanation'/, f
    assert_match /div class="control-group error"\>.*?\<input .*?name="crud_test_model\[name\]" .*?type="text"/, f
    assert_match /select .*?name="crud_test_model\[birthdate\(1i\)\]"/, f
    assert_match /option selected="selected" value="1910">1910<\/option>/, f
    assert_match /option selected="selected" value="1">January<\/option>/, f
    assert_match /option selected="selected" value="1">1<\/option>/, f
  end

  test "crud form" do
    f = with_test_routing do
      capture { crud_form }
    end

    assert_match /form .*?action="\/crud_test_models\/#{entry.id}"/, f
    assert_match /input .*?name="crud_test_model\[name\]" .*?type="text"/, f
    assert_match /input .*?name="crud_test_model\[whatever\]" .*?type="text"/, f
    assert_match /input .*?name="crud_test_model\[children\]" .*?type="number"/, f
    assert_match /input .*?name="crud_test_model\[rating\]" .*?type="number"/, f
    assert_match /input .*?name="crud_test_model\[income\]" .*?type="number"/, f
    assert_match /select .*?name="crud_test_model\[birthdate\(1i\)\]"/, f
    assert_match /input .*?name="crud_test_model\[human\]" .*?type="checkbox"/, f
    assert_match /select .*?name="crud_test_model\[companion_id\]"/, f
    assert_match /textarea .*?name="crud_test_model\[remarks\]"/, f
    assert_match /a .*href="\/crud_test_models\/#{entry.id}\?returning=true".*>Cancel<\/a>/, f
  end

  def entry
    @entry ||= CrudTestModel.first
  end
end
