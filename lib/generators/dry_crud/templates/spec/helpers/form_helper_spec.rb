# encoding: UTF-8
require 'rails_helper'

describe FormHelper do

  include UtilityHelper
  include FormatHelper
  include I18nHelper
  include CrudTestHelper

  before(:all) do
    reset_db
    setup_db
    create_test_data
  end

  after(:all) { reset_db }

  describe '#plain_form' do
    subject do
      with_test_routing do
        capture do
          plain_form(entry, html: { class: 'special' }) do |f|
            f.labeled_input_fields :name, :birthdate
          end
        end
      end
    end

    context 'for existing entry' do
      let(:entry) { crud_test_models(:AAAAA) }

      it do
        is_expected.to match(/form .*?class="special\ form-horizontal"
                                   .*?action="\/crud_test_models\/#{entry.id}"
                                   .*?method="post"/x)
      end

      it do
        is_expected.to match(/input .*?type="hidden"
                                    .*?name="_method"
                                    .*?value="(put|patch)"/x)
      end

      it do
        is_expected.to match(/input .*?type="text"
                                    .*?value="AAAAA"
                                    .*?name="crud_test_model\[name\]"/x)
      end

      it do
        is_expected.to match(/input .*?value="1910-01-01"
                                    .*?type="date"
                                    .*?name="crud_test_model\[birthdate\]"/x)
      end
    end
  end

  describe '#standard_form' do

    subject do
      with_test_routing do
        capture do
          standard_form(entry,
                        :name, :children, :birthdate, :human,
                        cancel_url: '/somewhere',
                        html: { class: 'special' })
        end
      end
    end

    context 'for existing entry' do
      let(:entry) { crud_test_models(:AAAAA) }

      it do
        is_expected.to match(/form .*?class="special\ form-horizontal"
                                   .*?action="\/crud_test_models\/#{entry.id}"
                                   .*?method="post"/x)
      end

      it do
        is_expected.to match(/input .*?type="hidden"
                                    .*?name="_method"
                                    .*?value="(put|patch)"/x)
      end

      it do
        is_expected.to match(/input .*?type="text"
                                    .*?value="AAAAA"
                                    .*?name="crud_test_model\[name\]"/x)
      end

      it do
        is_expected.to match(/input .*?value="1910-01-01"
                                    .*?type="date"
                                    .*?name="crud_test_model\[birthdate\]"/x)
      end

      it do
        is_expected.to match(/input .*?type="number"
                                    .*?value=\"9\"
                                    .*?name="crud_test_model\[children\]"/x)
      end

      it do
        is_expected.to match(/input .*?type="checkbox"
                                    .*?name="crud_test_model\[human\]"/x)
      end

      it do
        is_expected.to match(/button\ .*?type="submit".*>
                              #{t('global.button.save')}
                              <\/button>/x)
      end

      it do
        is_expected.to match(/a\ .*href="\/somewhere".*>
                              #{t('global.button.cancel')}
                              <\/a>/x)
      end
    end

    context 'for invalid entry' do
      let(:entry) do
        e = crud_test_models(:AAAAA)
        e.name = nil
        e.valid?
        e
      end

      it do
        is_expected.to match(/div[^>]* id='error_explanation'/)
      end

      it do
        is_expected.to match(/div\ class="form-group\ has-error"\>.*?
                              \<input .*?type="text"
                                      .*?name="crud_test_model\[name\]"/x)
      end

      it do
        is_expected.to match(/input .*?type="hidden"
                                    .*?name="_method"
                                    .*?value="(put|patch)"/x)
      end
    end
  end

  describe '#crud_form' do
    let(:entry) { CrudTestModel.first }
    subject do
      with_test_routing { crud_form }
    end

    it do
      is_expected.to match(/form .*?action="\/crud_test_models\/#{entry.id}"/)
    end

    it do
      is_expected.to match(/input .*?type="text"
                                  .*?name="crud_test_model\[name\]"/x)
    end

    it do
      is_expected.to match(/input .*?type="text"
                                  .*?name="crud_test_model\[whatever\]"/x)
    end

    it do
      is_expected.to match(/input .*?type="number"
                                  .*?name="crud_test_model\[children\]"/x)
    end

    it do
      is_expected.to match(/input .*?type="number"
                                  .*?name="crud_test_model\[rating\]"/x)
    end

    it do
      is_expected.to match(/input .*?type="number"
                                  .*?name="crud_test_model\[income\]"/x)
    end

    it do
      is_expected.to match(/input .*?type="date"
                                  .*?name="crud_test_model\[birthdate\]"/x)
    end

    it do
      is_expected.to match(/input .*?type="time"
                                  .*?name="crud_test_model\[gets_up_at\]"/x)
    end

    it do
      is_expected.to match(/input .*?type="datetime\-local"
                                  .*?name="crud_test_model\[last_seen\]"/x)
    end

    it do
      is_expected.to match(/input .*?type="checkbox"
                                  .*?name="crud_test_model\[human\]"/x)
    end

    it do
      is_expected.to match(/select .*?name="crud_test_model\[companion_id\]"/)
    end

    it do
      is_expected.to match(/textarea .*?name="crud_test_model\[remarks\]"/)
    end

    it do
      is_expected.to match(/a\ .*href="\/crud_test_models\/#{entry.id}
                               \?returning=true".*>
                            #{t('global.button.cancel')}<\/a>/x)
    end
  end

end
