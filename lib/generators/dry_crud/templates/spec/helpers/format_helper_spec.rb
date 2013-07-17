# encoding: UTF-8
require 'spec_helper'

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

      it { should be_html_safe }
      its(:squish) do
        should =~ /^<dt>label<\/dt>
                   \ <dd\ class=['"]value['"]>value<\/dd>$/x
      end
    end

    context 'with empty value' do
      subject { labeled('label') { '' } }

      it { should be_html_safe }
      its(:squish) do
        should =~ /<dt>label<\/dt>
                   \ <dd\ class=['"]value['"]>
                   #{UtilityHelper::EMPTY_STRING}
                   <\/dd>$/x
      end
    end

    context 'with unsafe value' do
      subject { labeled('label') { 'value <unsafe>' } }

      it { should be_html_safe }
      its(:squish) do
        should =~ /<dt>label<\/dt>
                   \ <dd\ class=['"]value['"]>
                   value\ &lt;unsafe&gt;
                   <\/dd>$/x
      end
    end
  end

  describe '#labeled_attr' do
    subject { labeled_attr('foo', :size) }

    it { should be_html_safe }
    its(:squish) do
      should =~ /<dt>Size<\/dt>
                 \ <dd\ class=['"]value['"]>3\ chars<\/dd>$/x
    end
  end

  describe '#f' do

    context 'Floats' do
      it 'should add two digits' do
        f(1.0).should == '1.000'
      end

      it 'should truncate to two digits' do
        f(3.14159).should == '3.142'
      end

      it 'should add delimiters' do
        f(12345.6789).should == '12,345.679'
      end
    end

    context 'Booleans' do
      it 'true should print yes' do
        f(true).should == 'yes'
      end

      it 'false should print no' do
        f(false).should == 'no'
      end
    end

    context 'Dates' do
      it 'prints regular date' do
        f(Date.new(2013, 6, 9)).should == '2013-06-09'
      end
    end

    context 'Times' do
      it 'prints regular date' do
        f(Time.utc(2013, 6, 9, 21, 25)).should == '2013-06-09 21:25'
      end
    end

    context 'nil' do
      it 'should print an empty string' do
        f(nil).should == UtilityHelper::EMPTY_STRING
      end
    end

    context 'Strings' do
      it 'should print regular strings unchanged' do
        f('blah blah').should == 'blah blah'
      end

      it 'should not be html safe' do
        f('<injection>').should_not be_html_safe
      end
    end

  end

  describe '#format_attr' do
    it 'should use #f' do
      format_attr('12.342', :to_f).should == f(12.342)
    end

    it 'should use object attr format method if it exists' do
      format_attr('abcd', :size).should == '4 chars'
    end

    it 'should use general attr format method if it exists' do
      format_attr([1, 2], :size).should == '2 items'
    end

    it 'should format empty belongs_to' do
      format_attr(crud_test_models(:AAAAA), :companion).should ==
        t('global.associations.no_entry')
    end

    it 'should format existing belongs_to' do
      string = format_attr(crud_test_models(:BBBBB), :companion)
      string.should == 'AAAAA'
    end

    it 'should format existing has_many' do
      string = format_attr(crud_test_models(:CCCCC), :others)
      string.should be_html_safe
      string.should == '<ul><li>AAAAA</li><li>BBBBB</li></ul>'
    end
  end

  describe '#column_type' do
    let(:model) { crud_test_models(:AAAAA) }

    it 'should recognize types' do
      column_type(model, :name).should == :string
      column_type(model, :children).should == :integer
      column_type(model, :companion_id).should == :integer
      column_type(model, :rating).should == :float
      column_type(model, :income).should == :decimal
      column_type(model, :birthdate).should == :date
      column_type(model, :gets_up_at).should == :time
      column_type(model, :last_seen).should == :datetime
      column_type(model, :human).should == :boolean
      column_type(model, :remarks).should == :text
      column_type(model, :companion).should be_nil
    end
  end

  describe '#format_type' do
    let(:model) { crud_test_models(:AAAAA) }

    it 'should format integers' do
      model.children = 10000
      format_type(model, :children).should == '10000'
    end

    it 'should format floats' do
      format_type(model, :rating).should == '1.100'
    end

    it 'should format decimals' do
      format_type(model, :income).should == '10,000,000.100'
    end

    it 'should format dates' do
      format_type(model, :birthdate).should == '1910-01-01'
    end

    it 'should format times' do
      format_type(model, :gets_up_at).should == '01:01'
    end

    it 'should format datetimes' do
      format_type(model, :last_seen).should == '2010-01-01 11:21'
    end

    it 'should format texts' do
      string = format_type(model, :remarks)
      string.should be_html_safe
      string.should == "<p>AAAAA BBBBB CCCCC\n<br />AAAAA BBBBB CCCCC\n</p>"
    end

    it 'should escape texts' do
      model.remarks = '<unsecure>bla'
      string = format_type(model, :remarks)
      string.should be_html_safe
      string.should == '<p>&lt;unsecure&gt;bla</p>'
    end

    it 'should format empty texts' do
      model.remarks = '   '
      string = format_type(model, :remarks)
      string.should be_html_safe
      string.should == UtilityHelper::EMPTY_STRING
    end
  end

  describe '#captionize' do
    it 'should handle symbols' do
      captionize(:camel_case).should == 'Camel Case'
    end

    it 'should render all upper case' do
      captionize('all upper case').should == 'All Upper Case'
    end

    it 'should render human attribute name' do
      captionize(:gets_up_at, CrudTestModel).should == 'Gets up at'
    end
  end

end
