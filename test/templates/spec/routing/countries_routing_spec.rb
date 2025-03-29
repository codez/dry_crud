require "rails_helper"

describe Admin::CountriesController do
  it "routes index" do
    expect(get: "admin/countries").to route_to(
      controller: "admin/countries", action: "index"
    )
  end

  it "routes show" do
    expect(get: "admin/countries/1").to route_to(
      controller: "admin/countries", action: "show", id: "1"
    )
  end
end
