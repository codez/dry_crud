# encoding: UTF-8
require 'spec_helper'

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
  if Rails.version < '4.0'
    let(:form)  do
      DryCrud::Form::Builder.new(:entry, entry, self, {}, ->(form) { form })
    end
  else
    let(:form)  { DryCrud::Form::Builder.new(:entry, entry, self, {}) }
  end

  describe '#input_field' do

    it 'dispatches name attr to string field' do
      form.should_receive(:string_field)
          .with(:name, class: 'form-control', required: 'required')
          .and_return('<input>')
      form.input_field(:name)
    end

    it { form.input_field(:name).should be_html_safe }

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
      more_ids: :has_many_field,
    }.each do |attr, method|
      it 'dispatches #{attr} attr to #{method}' do
        form.should_receive(method).with(attr, class: 'form-control')
        form.input_field(attr)
      end

      it { form.input_field(attr).should be_html_safe }
    end

  end

  describe '#labeled_input_fields' do
    subject { form.labeled_input_fields(:name, :remarks, :children) }

    it { should be_html_safe }
    it { should include(form.input_field(:name, required: 'required')) }
    it { should include(form.input_field(:remarks)) }
    it { should include(form.input_field(:children)) }
  end

  describe '#labeled_input_field' do
    context 'when required' do
      subject { form.labeled_input_field(:name) }
      it { should include('input-group-addon') }
    end

    context 'when not required' do
      subject { form.labeled_input_field(:remarks) }
      it { should_not include('input-group-addon') }
    end

    context 'with help text' do
      subject { form.labeled_input_field(:name, help: 'Some Help') }
      it { should include(form.help_block('Some Help')) }
    end
  end

  describe '#belongs_to_field' do
    it 'has all options by default' do
      f = form.belongs_to_field(:companion_id)
      f.scan('</option>').should have(7).items
    end

    it 'with has options from :list option' do
      list = CrudTestModel.all
      f = form.belongs_to_field(:companion_id,
                                list: [list.first, list.second])
      f.scan('</option>').should have(3).items
    end

    it 'with empty instance list has no select' do
      assign(:companions, [])
      @companions = []
      f = form.belongs_to_field(:companion_id)
      f.should match t('global.associations.none_available')
      f.scan('</option>').should have(0).items
    end
  end

  describe '#has_and_belongs_to_many_field' do
    let(:others) { OtherCrudTestModel.all[0..1] }

    it 'has all options by default' do
      f = form.has_many_field(:other_ids)
      f.scan('</option>').should have(6).items
    end

    it 'uses options from :list option if given' do
      f = form.has_many_field(:other_ids, list: others)
      f.scan('</option>').should have(2).items
    end

    it 'uses options form instance variable if given' do
      assign(:others, others)
      @others = others
      f = form.has_many_field(:other_ids)
      f.scan('</option>').should have(2).items
    end

    it 'displays a message for an empty list' do
      @others = []
      f = form.has_many_field(:other_ids)
      f.should match t('global.associations.none_available')
      f.scan('</option>').should have(0).items
    end
  end

  describe '#string_field' do
    it 'sets maxlength if attr has a limit' do
      form.string_field(:name).should match /maxlength="50"/
    end
  end

  describe '#label' do
    context 'only with attr' do
      subject { form.label(:gugus_dada) }

      it { should be_html_safe }
      it 'provides the same interface as rails' do
        should match /label [^>]*for.+Gugus dada/
      end
    end

    context 'with attr and text' do
      subject { form.label(:gugus_dada, 'hoho') }

      it { should be_html_safe }
      it 'provides the same interface as rails' do
        should match /label [^>]*for.+hoho/
      end
    end

  end

  describe '#labeled' do
    context 'in labeled_ method' do
      subject { form.labeled_string_field(:name) }

      it { should be_html_safe }
      it 'provides the same interface as rails' do
        should match /label [^>]*for.+input/m
      end
    end

    context 'with custom content in argument' do
      subject do
        form.labeled('gugus', "<input type='text' name='gugus' />".html_safe)
      end

      it { should be_html_safe }
      it { should match /label [^>]*for.+<input/m }
    end

    context 'with custom content in block' do
      subject do
        form.labeled('gugus') do
          "<input type='text' name='gugus' />".html_safe
        end
      end

      it { should be_html_safe }
      it { should match /label [^>]*for.+<input/m }
    end

    context 'with caption and content in argument' do
      subject do
        form.labeled('gugus',
                     "<input type='text' name='gugus' />".html_safe,
                     caption: 'Caption')
      end

      it { should be_html_safe }
      it { should match /label [^>]*for.+>Caption<\/label>.*<input/m }
    end

    context 'with caption and content in block' do
      subject do
        form.labeled('gugus', caption: 'Caption') do
          "<input type='text' name='gugus' />".html_safe
        end
      end

      it { should be_html_safe }
      it { should match /label [^>]*for.+>Caption<\/label>.*<input/m }
    end
  end

  it 'handles missing methods' do
    expect { form.blabla }.to raise_error(NoMethodError)
  end

  context '#respond_to?' do
    it 'returns false for non existing methods' do
      form.respond_to?(:blabla).should be_false
    end

    it 'returns true for existing methods' do
      form.respond_to?(:text_field).should be_true
    end

    it 'returns true for labeled_ methods' do
      form.respond_to?(:labeled_text_field).should be_true
    end
  end
end
