require 'test_helper'
require File.join(File.dirname(__FILE__), 'crud_controller_test_helper')

class CitiesControllerTest < ActionController::TestCase
  
  include CrudControllerTestHelper
  
  def test_setup
    assert_equal 3, City.count
    assert_recognizes({:controller => 'cities', :action => 'index'}, '/cities')
    assert_recognizes({:controller => 'cities', :action => 'show', :id => '1'}, '/cities/1')
  end
  
  def test_index
    super
    assert_equal 3, assigns(:entries).size
    assert_equal City.all(:order => 'country_code, name'), assigns(:entries)
  end
  
  protected   
  
  def test_entry
    cities(:rj)
  end
  
  def test_entry_attrs
    {:name => 'Rejkiavik', :country_code => 'IS'}
  end
  
end
