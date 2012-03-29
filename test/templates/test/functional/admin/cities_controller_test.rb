require 'test_helper'
require File.join('functional', 'crud_controller_test_helper')

class Admin::CitiesControllerTest < ActionController::TestCase

  include CrudControllerTestHelper

  def test_setup
    assert_equal 3, City.count
    assert_recognizes({:controller => 'admin/cities', :action => 'index', :country_id => '1'}, 'admin/countries/1/cities')
    assert_recognizes({:controller => 'admin/cities', :action => 'show', :country_id => '2', :id => '1'}, 'admin/countries/2/cities/1')
  end

  def test_index
    super
    assert_equal test_entry.country.cities.order('countries.code, cities.name').to_a, assigns(:entries).to_a
    
    assert_equal [:admin, test_entry.country], @controller.send(:parents)
    assert_equal test_entry.country, @controller.send(:parent)
    assert_equal test_entry.country.cities, @controller.send(:model_scope)
    assert_equal [:admin, test_entry.country, 2], @controller.send(:path_args, 2)
  end
# 
  # def test_show
    # get :show, test_params(:id => test_entry.id)
    # assert_redirected_to_index
  # end
#   
  # def test_show_with_non_existing_id_raises_RecordNotFound #not
    # get :show, test_params(:id => 9999)
    # assert_redirected_to_index
  # end
#   
  def test_create
    super
    assert_equal test_entry.country, assigns(:entry).country
  end

  def test_destroy_with_inhabitants
    ny = cities(:ny)
    assert_no_difference('City.count') do
      request.env["HTTP_REFERER"]
      delete :destroy, :country_id => ny.country_id, :id => ny.id
    end
    assert_redirected_to :action => 'show'
    assert flash.alert
  end

  protected

  def test_entry
    cities(:rj)
  end

  def test_entry_attrs
    {:name => 'Rejkiavik'}
  end

end
