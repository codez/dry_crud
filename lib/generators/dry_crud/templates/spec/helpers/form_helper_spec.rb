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
        capture { plain_form(entry, :html => {:class => 'special'}) {|f| f.labeled_input_fields :name, :birthdate } }
      end
    end

    context 'for existing entry' do
      let(:entry) { crud_test_models(:AAAAA) }

      it { should match(/form .*?action="\/crud_test_models\/#{entry.id}" .*?class="special form-horizontal" .*?method="post"/) }
      it { should match(/input .*?name="_method" .*?type="hidden" .*?value="(put|patch)"/) }
      it { should match(/input .*?name="crud_test_model\[name\]" .*?type="text" .*?value="AAAAA"/) }
      it { should match(/select .*?name="crud_test_model\[birthdate\(1i\)\]"/) }
      it { should match(/option selected="selected" value="1910">1910<\/option>/) }
      it { should match(/option selected="selected" value="1">January<\/option>/) }
      it { should match(/option selected="selected" value="1">1<\/option>/) }
    end
  end

  describe '#standard_form' do

    subject do
      with_test_routing do
        capture do
          standard_form(entry,
                        :name, :children, :birthdate, :human,
                        :cancel_url => '/somewhere',
                        :html => {:class => 'special'})
        end
      end
    end

    context 'for existing entry' do
      let(:entry) { crud_test_models(:AAAAA) }

      it { should match(/form .*?action="\/crud_test_models\/#{entry.id}" .?class="special form-horizontal" .*?method="post"/) }
      it { should match(/input .*?name="_method" .*?type="hidden" .*?value="(put|patch)"/) }
      it { should match(/input .*?name="crud_test_model\[name\]" .*?type="text" .*?value="AAAAA"/) }
      it { should match(/select .*?name="crud_test_model\[birthdate\(1i\)\]"/) }
      it { should match(/option selected="selected" value="1910">1910<\/option>/) }
      it { should match(/option selected="selected" value="1">January<\/option>/) }
      it { should match(/option selected="selected" value="1">1<\/option>/) }
      it { should match(/input .*?name="crud_test_model\[children\]" .*?type="number" .*?value=\"9\"/) }
      it { should match(/input .*?name="crud_test_model\[human\]" .*?type="checkbox"/) }
      it { should match(/button .*?type="submit">Save<\/button>/) }
      it { should match(/a .*href="\/somewhere".*>Cancel<\/a>/) }
    end

    context 'for invalid entry' do
      let(:entry) do
        e = crud_test_models(:AAAAA)
        e.name = nil
        e.valid?
        e
      end

      it { should match(/div[^>]* id='error_explanation'/) }
      it { should match(/div class="control-group error"\>.*?\<input .*?name="crud_test_model\[name\]" .*?type="text"/) }
      it { should match(/input .*?name="_method" .*?type="hidden" .*?value="(put|patch)"/) }
    end
  end

  describe '#crud_form' do
    let(:entry) { CrudTestModel.first }
    subject do
      with_test_routing { crud_form }
    end

    it { should match /form .*?action="\/crud_test_models\/#{entry.id}"/ }
    it { should match /input .*?name="crud_test_model\[name\]" .*?type="text"/ }
    it { should match /input .*?name="crud_test_model\[whatever\]" .*?type="text"/ }
    it { should match /input .*?name="crud_test_model\[children\]" .*?type="number"/ }
    it { should match /input .*?name="crud_test_model\[rating\]" .*?type="number"/ }
    it { should match /input .*?name="crud_test_model\[income\]" .*?type="number"/ }
    it { should match /select .*?name="crud_test_model\[birthdate\(1i\)\]"/ }
    it { should match /input .*?name="crud_test_model\[human\]" .*?type="checkbox"/ }
    it { should match /select .*?name="crud_test_model\[companion_id\]"/ }
    it { should match /textarea .*?name="crud_test_model\[remarks\]"/ }
    it { should match(/a .*href="\/crud_test_models\/#{entry.id}\?returning=true".*>Cancel<\/a>/) }
  end

end
