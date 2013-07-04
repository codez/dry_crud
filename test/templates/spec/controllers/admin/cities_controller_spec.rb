# encoding: UTF-8
require 'spec_helper'

describe Admin::CitiesController do

  fixtures :all

  include_examples 'crud controller', {}

  let(:test_entry)       { cities(:rj) }
  let(:test_entry_attrs) { { :name => 'Rejkiavik' } }
  alias_method :new_entry_attrs, :test_entry_attrs
  alias_method :edit_entry_attrs, :test_entry_attrs

  it 'should load fixtures' do
    City.count.should == 3
  end

  describe_action :get, :index do
    it 'should be ordered by default scope' do
      expected = test_entry.country.cities.includes(:country).
                                           order('countries.code, cities.name')
      if expected.respond_to?(:references)
        expected = expected.references(:countries)
      end
      entries == expected
    end

    it 'should set parents' do
      controller.send(:parents).should == [:admin, test_entry.country]
    end

    it 'should set parent variable' do
      assigns(:country).should == test_entry.country
    end

    it 'should use correct model_scope' do
      controller.send(:model_scope).should == test_entry.country.cities
    end

    it 'should have correct path args' do
      controller.send(:path_args, 2).should == [:admin, test_entry.country, 2]
    end
  end

  describe_action :get, :show, :id => true do
    it 'should set parents' do
      controller.send(:parents).should == [:admin, test_entry.country]
    end

    it 'should set parent variable' do
      assigns(:country).should == test_entry.country
    end
  end

  describe_action :post, :create do
    let(:params) { { model_identifier => new_entry_attrs } }

    it 'should set parent' do
      entry.country.should == test_entry.country
    end
  end

  describe_action :delete, :destroy, :id => true do
    context 'with inhabitants' do
      let(:test_entry) { cities(:ny) }

      it 'should not remove city from database', :perform_request => false do
        expect { perform_request }.to change { City.count }.by(0)
      end

      it 'should redirect to referer', :perform_request => false do
        ref = @request.env['HTTP_REFERER'] =
          admin_country_city_url(test_entry.country, test_entry)
        perform_request
        should redirect_to(ref)
      end

      it_should_have_flash(:alert)
    end
  end

end
