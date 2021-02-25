require 'test_helper'
require 'support/crud_controller_test_helper'

module Admin
  # Cities Controller Test
  class CitiesControllerTest < ActionController::TestCase
    include CrudControllerTestHelper

    def test_setup
      assert_equal 3, City.count
      assert_recognizes({ controller: 'admin/cities',
                          action: 'index',
                          country_id: '1' },
                        'admin/countries/1/cities')
      assert_recognizes({ controller: 'admin/cities',
                          action: 'show',
                          country_id: '2',
                          id: '1' },
                        'admin/countries/2/cities/1')
    end

    def test_index
      super
      expected = test_entry.country.cities.includes(:country)
                           .order('countries.code, cities.name')
      expected = expected.references(:countries) if expected.respond_to?(:references)
      assert_equal expected.to_a, entries.to_a

      assert_equal [:admin, test_entry.country], @controller.send(:parents)
      assert_equal test_entry.country, @controller.send(:parent)
      assert_equal test_entry.country.cities.to_a,
                   @controller.send(:model_scope).to_a
      assert_equal [:admin, test_entry.country, 2],
                   @controller.send(:path_args, 2)
    end

    def test_show
      super
      assert_equal [:admin, test_entry.country], @controller.send(:parents)
      assert_equal test_entry.country, @controller.send(:parent)
    end

    def test_create
      super
      assert_equal test_entry.country, entry.country
    end

    def test_destroy_with_inhabitants
      ny = cities(:ny)
      assert_no_difference('City.count') do
        @request.env['HTTP_REFERER'] = admin_country_city_url(ny.country, ny)
        delete :destroy, params: { country_id: ny.country_id, id: ny.id }
      end
      assert_redirected_to [:admin, ny.country, ny]
      assert flash[:alert].present?
    end

    private

    def test_entry
      cities(:rj)
    end

    def test_entry_attrs
      { name: 'Rejkiavik' }
    end
  end
end
