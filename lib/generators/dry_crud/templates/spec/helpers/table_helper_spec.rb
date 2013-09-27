# encoding: UTF-8
require 'spec_helper'

describe TableHelper do

  include FormatHelper
  include UtilityHelper
  include I18nHelper
  include CrudTestHelper

  before(:all) do
    reset_db
    setup_db
    create_test_data
  end

  after(:all) { reset_db }

  describe '#plain_table' do
    subject { plain_table(%w(foo bar), :size) { |t| t.attrs :upcase } }

    it 'contains attrs' do
      should match(/<th>Size<\/th>/)
    end

    it 'contains block' do
      should match(/<th>Upcase<\/th>/)
    end
  end

  describe '#plain_table_or_message' do
    context 'with empty data' do
      subject { plain_table_or_message([]) }

      it { should be_html_safe }

      it 'handles empty data' do
        should match(/div class=.table.\>.+\<\/div\>/)
      end
    end

    context 'with data' do
      subject do
        plain_table_or_message(%w(foo bar), :size) { |t| t.attrs :upcase }
      end

      it { should be_html_safe }

      it 'renders table' do
        should match(/^\<table.*\<\/table\>$/)
      end
    end
  end

  describe '#list_table' do
    let(:entries) { CrudTestModel.all }

    context 'default' do
      subject do
        with_test_routing { list_table }
      end

      it 'has 7 rows' do
        subject.scan(REGEXP_ROWS).size.should == 7
      end

      it 'has 14 sortable headers' do
        subject.scan(REGEXP_SORT_HEADERS).size.should == 14
      end
    end

    context 'with custom attributes' do
      subject do
        with_test_routing { list_table(:name, :children, :companion_id) }
      end

      it 'has 7 rows' do
        subject.scan(REGEXP_ROWS).size.should == 7
      end

      it 'has 3 sortable headers' do
        subject.scan(REGEXP_SORT_HEADERS).size.should == 3
      end
    end

    context 'with custom block' do
      subject do
        with_test_routing do
          list_table do |t|
            t.attrs :name, :children, :companion_id
            t.col('head') { |e| content_tag(:span, e.income.to_s) }
          end
        end
      end

      it 'has 7 rows' do
        subject.scan(REGEXP_ROWS).size.should == 7
      end

      it 'has 4 headers' do
        subject.scan(REGEXP_HEADERS).size.should == 4
      end

      it 'has 0 sortable headers' do
        subject.scan(REGEXP_SORT_HEADERS).size.should == 0
      end

      it 'has 6 spans' do
        subject.scan(/<span>.+?<\/span>/).size.should == 6
      end
    end

    context 'with custom attributes and block' do
      subject do
        with_test_routing do
          list_table(:name, :children, :companion_id) do |t|
            t.col('head') { |e| content_tag(:span, e.income.to_s) }
          end
        end
      end

      it 'has 7 rows' do
        subject.scan(REGEXP_ROWS).size.should == 7
      end

      it 'has 4 headers' do
        subject.scan(REGEXP_HEADERS).size.should == 4
      end

      it 'has 3 sortable headers' do
        subject.scan(REGEXP_SORT_HEADERS).size.should == 3
      end

      it 'has 6 spans' do
        subject.scan(/<span>.+?<\/span>/).size.should == 6
      end
    end

    context 'with ascending sort params' do
      let(:params) { { sort: 'children', sort_dir: 'asc' } }
      subject do
        with_test_routing { list_table }
      end

      it 'has 13 sortable headers' do
        subject.scan(REGEXP_SORT_HEADERS).size.should == 13
      end

      it 'has 1 ascending sort headers' do
        subject.scan(/<th><a .*?sort_dir=desc.*?>Children<\/a> &darr;<\/th>/)
               .size.should == 1
      end
    end

    context 'with descending sort params' do
      let(:params) { { sort: 'children', sort_dir: 'desc' } }
      subject do
        with_test_routing { list_table }
      end

      it 'has 13 sortable headers' do
        subject.scan(REGEXP_SORT_HEADERS).size.should == 13
      end

      it 'has 1 descending sort headers' do
        subject.scan(/<th><a .*?sort_dir=asc.*?>Children<\/a> &uarr;<\/th>/)
               .size.should == 1
      end
    end

    context 'with custom column sort params' do
      let(:params) { { sort: 'chatty', sort_dir: 'asc' } }
      subject do
        with_test_routing { list_table(:name, :children, :chatty) }
      end

      it 'has 2 sortable headers' do
        subject.scan(REGEXP_SORT_HEADERS).size.should == 2
      end

      it 'has 1 ascending sort headers' do
        subject.scan(/<th><a .*?sort_dir=desc.*?>Chatty<\/a> &darr;<\/th>/)
               .size.should == 1
      end
    end
  end

  describe '#crud_table' do
    let(:entries) { CrudTestModel.all }

    context 'default' do
      subject do
        with_test_routing { crud_table }
      end

      it 'has 7 rows' do
        subject.scan(REGEXP_ROWS).size.should == 7
      end

      it 'has 14 sort headers' do
        subject.scan(REGEXP_SORT_HEADERS).size.should == 14
      end

      it 'has 12 action cells' do
        subject.scan(REGEXP_ACTION_CELL).size.should == 12
      end
    end

    context 'with custom attrs' do
      subject do
        with_test_routing { crud_table(:name, :children, :companion_id) }
      end

      it 'has 3 sort headers' do
        subject.scan(REGEXP_SORT_HEADERS).size.should == 3
      end
    end

    context 'with custom block' do
      subject do
        with_test_routing do
          crud_table do |t|
            t.attrs :name, :children, :companion_id
            t.col('head') { |e| content_tag(:span, e.income.to_s) }
          end
        end
      end

      it 'has 4 headers' do
        subject.scan(REGEXP_HEADERS).size.should == 6
      end

      it 'has 6 custom col spans' do
        subject.scan(/<span>.+?<\/span>/m).size.should == 6
      end

      it 'has 12 action cells' do
        subject.scan(REGEXP_ACTION_CELL).size.should == 12
      end
    end

    context 'with custom attributes and block' do
      subject do
        with_test_routing do
          crud_table(:name, :children, :companion_id) do |t|
            t.col('head') { |e| content_tag(:span, e.income.to_s) }
          end
        end
      end

      it 'has 3 sort headers' do
        subject.scan(REGEXP_SORT_HEADERS).size.should == 3
      end

      it 'has 6 custom col spans' do
        subject.scan(/<span>.+?<\/span>/m).size.should == 6
      end

      it 'has 12 action cells' do
        subject.scan(REGEXP_ACTION_CELL).size.should == 12
      end
    end
  end

end
