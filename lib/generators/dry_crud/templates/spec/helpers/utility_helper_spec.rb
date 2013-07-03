# encoding: UTF-8
require 'spec_helper'

describe UtilityHelper do

  include CrudTestHelper

  before(:all) do
    reset_db
    setup_db
    create_test_data
  end

  after(:all) { reset_db }

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

  describe '#content_tag_nested' do

    it 'should escape safe content' do
      html = content_tag_nested(:div, ['a', 'b']) { |e| content_tag(:span, e) }
      html.should be_html_safe
      html.should == '<div><span>a</span><span>b</span></div>'
    end

    it 'should escape unsafe content' do
      html = content_tag_nested(:div, ['a', 'b']) { |e| "<#{e}>" }
      html.should == '<div>&lt;a&gt;&lt;b&gt;</div>'
    end

    it 'should simply join without block' do
      html = content_tag_nested(:div, ['a', 'b'])
      html.should == '<div>ab</div>'
    end
  end

  describe '#safe_join' do
    it 'should works as super without block' do
      html = safe_join(['<a>', '<b>'.html_safe])
      html.should == '&lt;a&gt;<b>'
    end

    it 'should collect contents for array' do
      html = safe_join(['a', 'b']) { |e| content_tag(:span, e) }
      html.should == '<span>a</span><span>b</span>'
    end
  end

  describe '#default_crud_attrs' do
    it 'do not contain id and password' do
      default_crud_attrs.should ==
        [:name, :email, :whatever, :children, :companion_id, :rating, :income,
         :birthdate, :gets_up_at, :last_seen, :human, :remarks,
         :created_at, :updated_at]
      end
  end

end
