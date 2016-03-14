# encoding: UTF-8
require 'rails_helper'

describe Admin::CitiesController do

  fixtures :all

  include_examples 'crud controller', {}

  let(:test_entry)       { cities(:rj) }
  let(:test_entry_attrs) { { name: 'Rejkiavik' } }
  alias_method :new_entry_attrs, :test_entry_attrs
  alias_method :edit_entry_attrs, :test_entry_attrs

  it 'loads fixtures' do
    expect(City.count).to eq(3)
  end

  describe_action :get, :index do
    it 'is ordered by default scope' do
      expected = test_entry.country.cities.includes(:country)
                                          .order('countries.code, cities.name')
      if expected.respond_to?(:references)
        expected = expected.references(:countries)
      end
      entries == expected
    end

    it 'sets parents' do
      expect(controller.send(:parents)).to eq([:admin, test_entry.country])
    end

    it 'sets parent variable' do
      expect(ivar(:country)).to eq(test_entry.country)
    end

    it 'uses correct model_scope' do
      expect(controller.send(:model_scope)).to eq(test_entry.country.cities)
    end

    it 'has correct path args' do
      expect(controller.send(:path_args, 2)).to eq(
        [:admin, test_entry.country, 2])
    end
  end

  describe_action :get, :show, id: true do
    it 'sets parents' do
      expect(controller.send(:parents)).to eq([:admin, test_entry.country])
    end

    it 'sets parent variable' do
      expect(ivar(:country)).to eq(test_entry.country)
    end
  end

  describe_action :post, :create do
    let(:params) { { model_identifier => new_entry_attrs } }

    it 'sets parent' do
      expect(entry.country).to eq(test_entry.country)
    end
  end

  describe_action :delete, :destroy, id: true do
    context 'with inhabitants' do
      let(:test_entry) { cities(:ny) }

      it 'does not remove city from database', perform_request: false do
        expect { perform_request }.to change { City.count }.by(0)
      end

      it 'redirects to referer', perform_request: false do
        ref = @request.env['HTTP_REFERER'] =
          admin_country_city_url(test_entry.country, test_entry)
        perform_request
        is_expected.to redirect_to(ref)
      end

      it_is_expected_to_have_flash(:alert)
    end
  end

end
