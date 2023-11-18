require 'rails_helper'

describe 'DryCrud::Form::Builder' do

  include FormatHelper
  include FormHelper
  include UtilityHelper
  include I18nHelper
  include CrudTestHelper

  before(:all) do
    reset_db
    setup_db
    create_test_data
  end

  after(:all) { reset_db }

  let(:entry) { CrudTestModel.first }
  let(:form)  { DryCrud::Form::Builder.new(:entry, entry, self, {}) }

  describe '#input_field' do

    it 'dispatches name attr to string field' do
      expect(form).to receive(:string_field)
        .with(:name, required: 'required')
        .and_return('<input>')
      form.input_field(:name)
    end

    it { expect(form.input_field(:name)).to be_html_safe }

    { password: :password_field,
      email: :email_field,
      remarks: :text_area,
      children: :integer_field,
      human: :boolean_field,
      birthdate: :date_field,
      gets_up_at: :time_field,
      last_seen: :datetime_field,
      companion_id: :belongs_to_field,
      other_ids: :has_many_field,
      more_ids: :has_many_field }.each do |attr, method|
      it "dispatches #{attr} attr to #{method}" do
        expect(form).to receive(method).with(attr)
        form.input_field(attr)
      end

      it { expect(form.input_field(attr)).to be_html_safe }
    end

  end

  describe '#labeled_input_fields' do
    subject { form.labeled_input_fields(:name, :remarks, :children) }

    it { is_expected.to be_html_safe }
    it { is_expected.to include(form.input_field(:name, required: 'required')) }
    it { is_expected.to include(form.input_field(:remarks)) }
    it { is_expected.to include(form.input_field(:children)) }
  end

  describe '#labeled_input_field' do
    context 'when required' do
      subject { form.labeled_input_field(:name) }
      it { is_expected.to include('input-group-text') }
    end

    context 'when not required' do
      subject { form.labeled_input_field(:remarks) }
      it { is_expected.not_to include('input-group-text') }
    end

    context 'with help text' do
      subject { form.labeled_input_field(:name, help: 'Some Help') }
      it { is_expected.to include(form.help_block('Some Help')) }
    end
  end

  describe '#belongs_to_field' do
    it 'has all options by default' do
      f = form.belongs_to_field(:companion_id)
      expect_n_options(f, 7)
    end

    it 'with has options from :list option' do
      list = CrudTestModel.all
      f = form.belongs_to_field(:companion_id,
                                list: [list.first, list.second])
      expect_n_options(f, 3)
    end

    it 'with empty instance list has no select' do
      assign(:companions, [])
      @companions = []
      f = form.belongs_to_field(:companion_id)
      expect(f).to match t('global.associations.none_available')
      expect_n_options(f, 0)
    end
  end

  describe '#has_and_belongs_to_many_field' do
    let(:others) { OtherCrudTestModel.all[0..1] }

    it 'has all options by default' do
      f = form.has_many_field(:other_ids)
      expect_n_options(f, 6)
    end

    it 'uses options from :list option if given' do
      f = form.has_many_field(:other_ids, list: others)
      expect_n_options(f, 2)
    end

    it 'uses options form instance variable if given' do
      assign(:others, others)
      @others = others
      f = form.has_many_field(:other_ids)
      expect_n_options(f, 2)
    end

    it 'displays a message for an empty list' do
      @others = []
      f = form.has_many_field(:other_ids)
      expect(f).to match t('global.associations.none_available')
      expect_n_options(f, 0)
    end
  end

  describe '#string_field' do
    it 'sets maxlength if attr has a limit' do
      expect(form.string_field(:name)).to match(/maxlength="50"/)
    end
  end

  describe '#label' do
    context 'only with attr' do
      subject { form.label(:gugus_dada) }

      it { is_expected.to be_html_safe }
      it 'provides the same interface as rails' do
        is_expected.to match(/label [^>]*for.+Gugus dada/)
      end
    end

    context 'with attr and text' do
      subject { form.label(:gugus_dada, 'hoho') }

      it { is_expected.to be_html_safe }
      it 'provides the same interface as rails' do
        is_expected.to match(/label [^>]*for.+hoho/)
      end
    end

  end

  describe '#labeled' do
    context 'in labeled_ method' do
      subject { form.labeled_string_field(:name) }

      it { is_expected.to be_html_safe }
      it 'provides the same interface as rails' do
        is_expected.to match(/label [^>]*for.+input/m)
      end
    end

    context 'with custom content in argument' do
      subject do
        form.labeled('gugus', "<input type='text' name='gugus' />".html_safe)
      end

      it { is_expected.to be_html_safe }
      it { is_expected.to match(/label [^>]*for.+<input/m) }
    end

    context 'with custom content in block' do
      subject do
        form.labeled('gugus') do
          "<input type='text' name='gugus' />".html_safe
        end
      end

      it { is_expected.to be_html_safe }
      it { is_expected.to match(/label [^>]*for.+<input/m) }
    end

    context 'with caption and content in argument' do
      subject do
        form.labeled('gugus',
                     "<input type='text' name='gugus' />".html_safe,
                     caption: 'Caption')
      end

      it { is_expected.to be_html_safe }
      it { is_expected.to match(/label [^>]*for.+>Caption<\/label>.*<input/m) }
    end

    context 'with caption and content in block' do
      subject do
        form.labeled('gugus', caption: 'Caption') do
          "<input type='text' name='gugus' />".html_safe
        end
      end

      it { is_expected.to be_html_safe }
      it { is_expected.to match(/label [^>]*for.+>Caption<\/label>.*<input/m) }
    end
  end

  it 'handles missing methods' do
    expect { form.blabla }.to raise_error(NoMethodError)
  end

  context '#respond_to?' do
    it 'returns false for non existing methods' do
      expect(form.respond_to?(:blabla)).to be false
    end

    it 'returns true for existing methods' do
      expect(form.respond_to?(:text_field)).to be true
    end

    it 'returns true for labeled_ methods' do
      expect(form.respond_to?(:labeled_text_field)).to be true
    end
  end

  def expect_n_options(form, count)
    expect(form.scan('</option>').size).to eq(count)
  end

end
