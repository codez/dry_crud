# encoding: UTF-8
require 'spec_helper'

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
        should match(/form .*?action="\/crud_test_models\/#{entry.id}"
                           .*?class="special\ form-horizontal"
                           .*?method="post"/x)
      end

      it do
        should match(/input .*?name="_method"
                            .*?type="hidden"
                            .*?value="(put|patch)"/x)
      end

      it do
        should match(/input .*?name="crud_test_model\[name\]"
                            .*?type="text"
                            .*?value="AAAAA"/x)
      end

      it do
        should match(/input .*?name="crud_test_model\[birthdate\]"
                            .*?type="date"
                            .*?value="1910-01-01"/x)
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
        should match(/form .*?action="\/crud_test_models\/#{entry.id}"
                            .*?class="special\ form-horizontal"
                            .*?method="post"/x)
      end

      it do
        should match(/input .*?name="_method"
                            .*?type="hidden"
                            .*?value="(put|patch)"/x)
      end

      it do
        should match(/input .*?name="crud_test_model\[name\]"
                             .*?type="text"
                             .*?value="AAAAA"/x)
      end

      it do
        should match(/input .*?name="crud_test_model\[birthdate\]"
                             .*?type="date"
                             .*?value="1910-01-01"/x)
      end

      it do
        should match(/input .*?name="crud_test_model\[children\]"
                            .*?type="number"
                            .*?value=\"9\"/x)
      end

      it do
        should match(/input .*?name="crud_test_model\[human\]"
                            .*?type="checkbox"/x)
      end

      it do
        should match(/button\ .*?type="submit">
                      #{t('global.button.save')}
                      <\/button>/x)
      end

      it do
        should match(/a\ .*href="\/somewhere".*>
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
        should match(/div[^>]* id='error_explanation'/)
      end

      it do
        should match(/div\ class="form-group\ has-error"\>.*?
                      \<input .*?name="crud_test_model\[name\]"
                              .*?type="text"/x)
      end

      it do
        should match(/input .*?name="_method"
                            .*?type="hidden"
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
      should match /form .*?action="\/crud_test_models\/#{entry.id}"/
    end

    it do
      should match /input .*?name="crud_test_model\[name\]"
                          .*?type="text"/x
    end

    it do
      should match /input .*?name="crud_test_model\[whatever\]"
                          .*?type="text"/x
    end

    it do
      should match /input .*?name="crud_test_model\[children\]"
                          .*?type="number"/x
    end

    it do
      should match /input .*?name="crud_test_model\[rating\]"
                          .*?type="number"/x
    end

    it do
      should match /input .*?name="crud_test_model\[income\]"
                          .*?type="number"/x
    end

    it do
      should match /input .*?name="crud_test_model\[birthdate\]"
                          .*?type="date"/x
    end

    it do
      should match /input .*?name="crud_test_model\[gets_up_at\]"
                          .*?type="time"/x
    end

    it do
      should match /input .*?name="crud_test_model\[last_seen\]"
                          .*?type="datetime"/x
    end

    it do
      should match /input .*?name="crud_test_model\[human\]"
                          .*?type="checkbox"/x
    end

    it do
      should match /select .*?name="crud_test_model\[companion_id\]"/
    end

    it do
      should match /textarea .*?name="crud_test_model\[remarks\]"/
    end

    it do
      should match(/a\ .*href="\/crud_test_models\/#{entry.id}
                               \?returning=true".*>
                    #{t('global.button.cancel')}<\/a>/x)
    end
  end

end
