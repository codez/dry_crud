# encoding: UTF-8
require 'rails_helper'

describe Admin::CitiesController do
  it 'routes index' do
    expect(get: 'admin/countries/1/cities').to route_to(
      controller: 'admin/cities', action: 'index', country_id: '1')
  end

  it 'routes show' do
    expect(get: 'admin/countries/2/cities/1').to route_to(
      controller: 'admin/cities', action: 'show', country_id: '2', id: '1')
  end
end
