require 'spec_helper'

describe Admin::CitiesController do
  it "should route index" do
    { :get => 'admin/countries/1/cities' }.should route_to({:controller => 'admin/cities', :action => 'index', :country_id => '1'})
  end
  
  it "should route show" do
    { :get => 'admin/countries/2/cities/1' }.should route_to({:controller => 'admin/cities', :action => 'show', :country_id => '2', :id => '1'})
  end
end
