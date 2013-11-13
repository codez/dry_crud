# encoding: UTF-8
require 'spec_helper'

describe Admin::CountriesController do
  it 'should route index' do
    { get: 'admin/countries' }.should(
      route_to(controller: 'admin/countries',
               action: 'index'))
  end

  it 'should route show' do
    { get: 'admin/countries/1' }.should(
      route_to(controller: 'admin/countries',
               action: 'show',
               id: '1'))
  end
end
