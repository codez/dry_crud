require "rails_helper"

describe PeopleController do
  fixtures :all

  render_views

  include_examples "crud controller", {}

  let(:test_entry)       { people(:john) }
  let(:test_entry_attrs) do
    { name: "Fischers Fritz",
      children: 2,
      income: 120,
      city_id: cities(:rj).id }
  end

  alias_method :new_entry_attrs, :test_entry_attrs
  alias_method :edit_entry_attrs, :test_entry_attrs

  it "loads fixtures" do
    expect(Person.count).to eq(2)
  end

  describe_action :get, :index do
    it "is ordered by default scope" do
      expected = Person.includes(city: :country)
                       .order("people.name, countries.code, cities.name")
      expected = expected.references(:cities, :countries) if expected.respond_to?(:references)
      entries == expected
    end

    it "sets parents" do
      expect(controller.send(:parents)).to eq([])
    end

    it "sets nil parent" do
      expect(controller.send(:parent)).to be_nil
    end

    it "uses correct model_scope" do
      expect(controller.send(:model_scope)).to eq(Person.all)
    end

    it "has correct path args" do
      expect(controller.send(:path_args, 2)).to eq([ 2 ])
    end
  end

  describe_action :get, :show, id: true do
    context "turbo", format: :turbo_stream do
      it_is_expected_to_respond
      it { expect(response.body).to match(/<turbo-stream action="update" target="content">/) }
    end
  end

  describe_action :get, :edit, id: true do
    context "turbo", format: :turbo_stream do
      it_is_expected_to_respond
      it { expect(response.body).to match(/<turbo-stream action="update" target="content">/) }
    end
  end

  describe_action :put, :update, id: true do
    context "turbo", format: :turbo_stream do
      context "with valid params" do
        let(:params) { { person: { name: "New Name" } } }

        it_is_expected_to_respond
        it { expect(response.body).to match(/<turbo-stream action="update" target="content">/) }
      end

      context "with invalid params" do
        let(:params) { { person: { name: " " } } }

        it_is_expected_to_respond
        it { expect(response.body).to match(/<turbo-stream action="update" target="content">/) }
      end
    end
  end
end
