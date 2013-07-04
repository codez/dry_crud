# encoding: UTF-8
require 'test_helper'
require 'support/crud_controller_test_helper'

# People Controller Test
class PeopleControllerTest < ActionController::TestCase

  include CrudControllerTestHelper

  def test_setup
    assert_equal 2, Person.count
    assert_recognizes({ :controller => 'people',
                        :action => 'index' },
                      '/people')
    assert_recognizes({ :controller => 'people',
                        :action => 'show',
                        :id => '1' },
                      '/people/1')
  end

  def test_index
    super
    assert_equal 2, entries.size
    expected = Person.includes(:city => :country).
                      order('people.name, countries.code, cities.name')
    if expected.respond_to?(:references)
      expected = expected.references(:cities, :countries)
    end
    assert_equal expected.to_a, entries

    assert_equal [], @controller.send(:parents)
    assert_nil @controller.send(:parent)
    assert_equal Person.all, @controller.send(:model_scope)
    assert_equal [2], @controller.send(:path_args, 2)
  end

  def test_index_search
    super
    assert_equal 1, entries.size
  end

  def test_show_js
    get :show, :id => test_entry.id, :format => :js
    assert_response :success
    assert_template 'show'
    assert_match /\$\('#content'\)/, response.body
  end

  def test_edit_js
    get :edit, :id => test_entry.id, :format => :js
    assert_response :success
    assert_template 'edit'
    assert_match /\$\('#content'\)/, response.body
  end

  def test_update_js
    put :update, :id => test_entry.id,
                 :format => :js,
                 :person => { :name => 'New Name' }
    assert_response :success
    assert_template 'update'
    assert_match /\$\('#content'\)/, response.body
  end

  def test_update_fail_js
    put :update, :id => test_entry.id,
                 :format => :js,
                 :person => { :name => ' ' }
    assert_response :success
    assert_template 'update'
    assert_match /alert/, response.body
  end

  private

  def test_entry
    people(:john)
  end

  def test_entry_attrs
    { :name => 'Fischers Fritz',
      :children => 2,
      :income => 120,
      :city_id => cities(:rj).id }
  end

end
