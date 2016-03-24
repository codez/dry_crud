# encoding: UTF-8
require 'rails_helper'

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

  describe '#content_tag_nested' do

    it 'escapes safe content' do
      html = content_tag_nested(:div, %w(a b)) { |e| content_tag(:span, e) }
      expect(html).to be_html_safe
      expect(html).to eq('<div><span>a</span><span>b</span></div>')
    end

    it 'escapes unsafe content' do
      html = content_tag_nested(:div, %w(a b)) { |e| "<#{e}>" }
      expect(html).to eq('<div>&lt;a&gt;&lt;b&gt;</div>')
    end

    it 'simplys join without block' do
      html = content_tag_nested(:div, %w(a b))
      expect(html).to eq('<div>ab</div>')
    end
  end

  describe '#safe_join' do
    it 'works as super without block' do
      html = safe_join(['<a>', '<b>'.html_safe])
      expect(html).to eq('&lt;a&gt;<b>')
    end

    it 'collects contents for array' do
      html = safe_join(%w(a b)) { |e| content_tag(:span, e) }
      expect(html).to eq('<span>a</span><span>b</span>')
    end
  end

  describe '#default_crud_attrs' do
    it 'do not contain id and password' do
      expect(default_crud_attrs).to eq(
        [:name, :email, :whatever, :children, :companion_id, :rating, :income,
         :birthdate, :gets_up_at, :last_seen, :human, :remarks,
         :created_at, :updated_at])
    end
  end

end
