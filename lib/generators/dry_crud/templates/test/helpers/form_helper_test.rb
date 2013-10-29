# encoding: UTF-8
require 'test_helper'
require 'support/crud_test_model'

# Test FormHelper
class FormHelperTest < ActionView::TestCase

  include UtilityHelper
  include FormatHelper
  include I18nHelper
  include CrudTestHelper

  setup :reset_db, :setup_db, :create_test_data
  teardown :reset_db

  test 'plain form for existing entry' do
    e = crud_test_models('AAAAA')
    f = with_test_routing do
      capture do
        plain_form(e, html: { class: 'special' }) do |form|
          form.labeled_input_fields :name, :birthdate
        end
      end
    end

    assert_match /form .*?action="\/crud_test_models\/#{e.id}"
                       .*?class="special\ form-horizontal"
                       .*?method="post"/x, f
    assert_match /input .*?name="_method"
                        .*?type="hidden"
                        .*?value="(patch|put)"/x, f
    assert_match /input .*?name="crud_test_model\[name\]"
                        .*?type="text"
                        .*?value="AAAAA"/x, f
  end

  test 'standard form' do
    e = crud_test_models('AAAAA')
    f = with_test_routing do
      capture do
        standard_form(e,
                      :name, :children, :birthdate, :human,
                      cancel_url: '/somewhere',
                      html: { class: 'special' })
      end
    end

    assert_match /form .*?action="\/crud_test_models\/#{e.id}"
                       .*?class="special\ form-horizontal"
                      .*?method="post"/x, f
    assert_match /input .*?name="_method"
                        .*?type="hidden"
                        .*?value="(patch|put)"/x, f
    assert_match /input .*?name="crud_test_model\[name\]"
                        .*?type="text"
                        .*?value="AAAAA"/x, f
    assert_match /input .*?name="crud_test_model\[birthdate\]"
                        .*?type="date"/x, f
    assert_match /input .*?name="crud_test_model\[children\]"
                        .*?type="number"
                        .*?value=\"9\"/x, f
    assert_match /input .*?name="crud_test_model\[human\]"
                        .*?type="checkbox"/x, f
    assert_match /button\ .*?type="submit"\>
                  #{t('global.button.save')}
                  \<\/button\>/x, f
    assert_match /\<a\ .*href="\/somewhere".*\>
                  #{t('global.button.cancel')}
                  \<\/a\>/x, f
  end

  test 'standard form with errors' do
    e = crud_test_models('AAAAA')
    e.name = nil
    assert !e.valid?

    f = with_test_routing do
      capture do
        standard_form(e) do |form|
          form.labeled_input_fields(:name, :birthdate)
        end
      end
    end

    assert_match /form .*?action="\/crud_test_models\/#{e.id}"
                       .*?method="post"/x, f
    assert_match /input .*?name="_method"
                        .*?type="hidden"
                        .*?value="(patch|put)"/x, f
    assert_match /div[^>]* id='error_explanation'/, f
    assert_match /div\ class="form-group\ has-error"\>.*?
                  \<input .*?name="crud_test_model\[name\]"
                          .*?type="text"/x, f
    assert_match /input .*?name="crud_test_model\[birthdate\]"
                        .*?type="date"
                        .*?value="1910-01-01"/x, f
  end

  test 'crud form' do
    f = with_test_routing do
      capture { crud_form }
    end

    assert_match /form .*?action="\/crud_test_models\/#{entry.id}"/, f
    assert_match /input .*?name="crud_test_model\[name\]"
                        .*?type="text"/x, f
    assert_match /input .*?name="crud_test_model\[whatever\]"
                        .*?type="text"/x, f
    assert_match /input .*?name="crud_test_model\[children\]"
                        .*?type="number"/x, f
    assert_match /input .*?name="crud_test_model\[rating\]"
                        .*?type="number"/x, f
    assert_match /input .*?name="crud_test_model\[income\]"
                        .*?type="number"/x, f
    assert_match /input .*?name="crud_test_model\[birthdate\]"
                        .*?type="date"/x, f
    assert_match /input .*?name="crud_test_model\[gets_up_at\]"
                        .*?type="time"/x, f
    assert_match /input .*?name="crud_test_model\[last_seen\]"
                        .*?type="datetime"/x, f
    assert_match /input .*?name="crud_test_model\[human\]"
                        .*?type="checkbox"/x, f
    assert_match /select .*?name="crud_test_model\[companion_id\]"/, f
    assert_match /textarea .*?name="crud_test_model\[remarks\]"/, f
    assert_match /a .*href="\/crud_test_models\/#{entry.id}\?returning=true"
                  .*>#{t('global.button.cancel')}<\/a>/x, f
  end

  def entry
    @entry ||= CrudTestModel.first
  end
end
