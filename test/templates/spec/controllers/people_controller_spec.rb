# encoding: UTF-8
require 'spec_helper'

describe PeopleController do

  fixtures :all

  render_views

  include_examples 'crud controller', {}

  let(:test_entry)       { people(:john) }
  let(:test_entry_attrs) do
    { :name => 'Fischers Fritz',
      :children => 2,
      :income => 120,
      :city_id => cities(:rj).id }
  end

  alias_method :new_entry_attrs, :test_entry_attrs
  alias_method :edit_entry_attrs, :test_entry_attrs

  it 'should load fixtures' do
    Person.count.should == 2
  end

  describe_action :get, :index do
    it 'should be ordered by default scope' do
      expected = Person.includes(:city => :country).
                        order('people.name, countries.code, cities.name')
      if expected.respond_to?(:references)
        expected = expected.references(:cities, :countries)
      end
      entries == expected
    end

    it 'should set parents' do
      controller.send(:parents).should == []
    end

    it 'should set nil parent' do
      controller.send(:parent).should be_nil
    end

    it 'should use correct model_scope' do
      controller.send(:model_scope).should == Person.all
    end

    it 'should have correct path args' do
      controller.send(:path_args, 2).should == [2]
    end
  end

  describe_action :get, :show, :id => true do
    context '.js', :format => :js do
      it_should_respond
      it_should_render
      its(:body) { should match(/\$\('#content'\)/) }
    end
  end

  describe_action :get, :edit, :id => true do
    context '.js', :format => :js do
      it_should_respond
      it_should_render
      its(:body) { should match(/\$\('#content'\)/) }
    end
  end

  describe_action :put, :update, :id => true do
    context '.js', :format => :js do
      context 'with valid params' do
        let(:params) { { :person => { :name => 'New Name' } } }

        it_should_respond
        it_should_render
        its(:body) { should match(/\$\('#content'\)/) }
      end

      context 'with invalid params' do
        let(:params) { { :person => { :name => ' ' } } }

        it_should_respond
        it_should_render
        its(:body) { should match(/alert/) }
      end
    end
  end
end
