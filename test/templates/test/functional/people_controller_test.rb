require 'test_helper'
require File.join(File.dirname(__FILE__), 'crud_controller_test_helper')

class PeopleControllerTest < ActionController::TestCase
  
  include CrudControllerTestHelper
  
  def test_setup
    assert_equal 2, Person.count
    assert_recognizes({:controller => 'people', :action => 'index'}, '/people')
    assert_recognizes({:controller => 'people', :action => 'show', :id => '1'}, '/people/1')
  end
  
  def test_index
    super
    assert_equal 2, assigns(:entries).size
    assert_equal Person.includes(:city).order('people.name, cities.country_code, cities.name').all, assigns(:entries)
  end
  
  def test_index_search
    super
  	assert_equal 1, assigns(:entries).size
  end
  
  protected 
  
  def test_entry
    people(:john)
  end
  
  def test_entry_attrs
    {:name => 'Fischers Fritz', :children => 2, :income => 120, :city_id => cities(:rj).id}
  end
  
end
