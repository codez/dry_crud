require "rails_helper"

describe Admin::CountriesController do
  fixtures :all

  include_examples "crud controller", skip: %w[show html plain]

  let(:test_entry)       { countries(:br) }
  let(:test_entry_attrs) do
    { name: "United States of America", code: "US" }
  end

  alias_method :new_entry_attrs, :test_entry_attrs
  alias_method :edit_entry_attrs, :test_entry_attrs

  it "loads fixtures" do
    expect(Country.count).to eq(3)
  end

  describe_action :get, :index do
    it "is ordered by default scope" do
      entries == Country.order(:name)
    end

    it "sets parents" do
      expect(controller.send(:parents)).to eq([ :admin ])
    end

    it "sets nil parent" do
      expect(controller.send(:parent)).to be_nil
    end

    it "uses correct model_scope" do
      expect(controller.send(:model_scope)).to eq(Country.all)
    end

    it "has correct path args" do
      expect(controller.send(:path_args, 2)).to eq([ :admin, 2 ])
    end
  end

  describe_action :get, :show do
    let(:params) { { id: test_entry.id } }
    it_is_expected_to_redirect_to_index
  end
end
