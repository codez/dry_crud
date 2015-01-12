# encoding: UTF-8
require 'rails_helper'

describe FormatHelper do

  include UtilityHelper
  include I18nHelper
  include CrudTestHelper

  before(:all) do
    reset_db
    setup_db
    create_test_data
  end

  after(:all) { reset_db }

  # define some test format_ methods
  def format_size(obj) #:nodoc:
    "#{f(obj.size)} items"
  end

  def format_string_size(obj) #:nodoc:
    "#{f(obj.size)} chars"
  end

  describe '#labeled' do
    context 'regular' do
      subject { labeled('label') { 'value' } }

      it { is_expected.to be_html_safe }
      it do
        expect(subject.squish).to match(
          /^<dt>label<\/dt>
           \ <dd\ class=['"]value['"]>value<\/dd>$/x)
      end
    end

    context 'with empty value' do
      subject { labeled('label') { '' } }

      it { is_expected.to be_html_safe }
      it do
        expect(subject.squish).to match(
          /<dt>label<\/dt>
           \ <dd\ class=['"]value['"]>
           #{UtilityHelper::EMPTY_STRING}
           <\/dd>$/x)
      end
    end

    context 'with unsafe value' do
      subject { labeled('label') { 'value <unsafe>' } }

      it { is_expected.to be_html_safe }
      it do
        expect(subject.squish).to match(
          /<dt>label<\/dt>
           \ <dd\ class=['"]value['"]>
           value\ &lt;unsafe&gt;
           <\/dd>$/x)
      end
    end
  end

  describe '#labeled_attr' do
    subject { labeled_attr('foo', :size) }

    it { is_expected.to be_html_safe }
    it do
      expect(subject.squish).to match(
        /<dt>Size<\/dt>
         \ <dd\ class=['"]value['"]>3\ chars<\/dd>$/x)
    end
  end

  describe '#f' do

    unless ENV['NON_LOCALIZED'] # localization dependent tests
      context 'Floats' do
        it 'adds two digits' do
          expect(f(1.0)).to eq('1.000')
        end

        it 'truncates to two digits' do
          expect(f(3.14159)).to eq('3.142')
        end

        it 'adds delimiters' do
          expect(f(12_345.6789)).to eq('12,345.679')
        end
      end

      context 'Booleans' do
        it 'true is_expected.to print yes' do
          expect(f(true)).to eq('yes')
        end

        it 'false is_expected.to print no' do
          expect(f(false)).to eq('no')
        end
      end

      context 'Dates' do
        it 'prints regular date' do
          expect(f(Date.new(2013, 6, 9))).to eq('2013-06-09')
        end
      end

      context 'Times' do
        it 'prints regular date' do
          expect(f(Time.utc(2013, 6, 9, 21, 25))).to eq('2013-06-09 21:25')
        end
      end
    end

    context 'nil' do
      it 'prints an empty string' do
        expect(f(nil)).to eq(UtilityHelper::EMPTY_STRING)
      end
    end

    context 'Strings' do
      it 'prints regular strings unchanged' do
        expect(f('blah blah')).to eq('blah blah')
      end

      it 'is not html safe' do
        expect(f('<injection>')).not_to be_html_safe
      end
    end

  end

  describe '#format_attr' do
    it 'uses #f' do
      expect(format_attr('12.342', :to_f)).to eq(f(12.342))
    end

    it 'uses object attr format method if it exists' do
      expect(format_attr('abcd', :size)).to eq('4 chars')
    end

    it 'uses general attr format method if it exists' do
      expect(format_attr([1, 2], :size)).to eq('2 items')
    end

    it 'formats empty belongs_to' do
      expect(format_attr(crud_test_models(:AAAAA), :companion)).to eq(
        t('global.associations.no_entry'))
    end

    it 'formats existing belongs_to' do
      string = format_attr(crud_test_models(:BBBBB), :companion)
      expect(string).to eq('AAAAA')
    end

    it 'formats existing has_many' do
      string = format_attr(crud_test_models(:CCCCC), :others)
      expect(string).to be_html_safe
      expect(string).to eq('<ul><li>AAAAA</li><li>BBBBB</li></ul>')
    end
  end

  describe '#column_type' do
    let(:model) { crud_test_models(:AAAAA) }

    it 'recognizes types' do
      expect(column_type(model, :name)).to eq(:string)
      expect(column_type(model, :children)).to eq(:integer)
      expect(column_type(model, :companion_id)).to eq(:integer)
      expect(column_type(model, :rating)).to eq(:float)
      expect(column_type(model, :income)).to eq(:decimal)
      expect(column_type(model, :birthdate)).to eq(:date)
      expect(column_type(model, :gets_up_at)).to eq(:time)
      expect(column_type(model, :last_seen)).to eq(:datetime)
      expect(column_type(model, :human)).to eq(:boolean)
      expect(column_type(model, :remarks)).to eq(:text)
      expect(column_type(model, :companion)).to be_nil
    end
  end

  describe '#format_type' do
    let(:model) { crud_test_models(:AAAAA) }

    it 'formats integers' do
      model.children = 10_000
      expect(format_type(model, :children)).to eq('10,000')
    end

    unless ENV['NON_LOCALIZED'] # localization dependent tests
      it 'formats floats' do
        expect(format_type(model, :rating)).to eq('1.100')
      end

      it 'formata decimals' do
        expect(format_type(model, :income)).to eq('10,000,000.1111')
      end

      it 'formats dates' do
        expect(format_type(model, :birthdate)).to eq('1910-01-01')
      end

      it 'formats times' do
        expect(format_type(model, :gets_up_at)).to eq('01:01')
      end

      it 'formats datetimes' do
        expect(format_type(model, :last_seen)).to eq('2010-01-01 11:21')
      end

      it 'formats boolean false' do
        model.human = false
        expect(format_type(model, :human)).to eq('no')
      end

      it 'formats boolean true' do
        model.human = true
        expect(format_type(model, :human)).to eq('yes')
      end
    end

    it 'formats texts' do
      string = format_type(model, :remarks)
      expect(string).to be_html_safe
      expect(string).to eq(
        "<p>AAAAA BBBBB CCCCC\n<br />AAAAA BBBBB CCCCC\n</p>")
    end

    it 'escapes texts' do
      model.remarks = '<unsecure>bla'
      string = format_type(model, :remarks)
      expect(string).to be_html_safe
      expect(string).to eq('<p>&lt;unsecure&gt;bla</p>')
    end

    it 'formats empty texts' do
      model.remarks = '   '
      string = format_type(model, :remarks)
      expect(string).to be_html_safe
      expect(string).to eq(UtilityHelper::EMPTY_STRING)
    end
  end

  describe '#captionize' do
    it 'handles symbols' do
      expect(captionize(:camel_case)).to eq('Camel Case')
    end

    it 'renders all upper case' do
      expect(captionize('all upper case')).to eq('All Upper Case')
    end

    it 'renders human attribute name' do
      expect(captionize(:gets_up_at, CrudTestModel)).to eq('Gets up at')
    end
  end

end
