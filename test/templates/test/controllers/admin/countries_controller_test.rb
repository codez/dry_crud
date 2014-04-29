# encoding: UTF-8
require 'test_helper'
require 'support/crud_controller_test_helper'

module Admin
  # Countries Controller Test
  class CountriesControllerTest < ActionController::TestCase

    include CrudControllerTestHelper

    def test_setup
      assert_equal 3, Country.count
      assert_recognizes({ controller: 'admin/countries',
                          action: 'index' },
                        'admin/countries')
      assert_recognizes({ controller: 'admin/countries',
                          action: 'show',
                          id: '1' },
                        'admin/countries/1')
    end

    def test_index
      super
      assert_equal Country.order('name').to_a, entries
      assert_equal [:admin], @controller.send(:parents)
      assert_nil @controller.send(:parent)
      assert_equal Country.all, @controller.send(:model_scope)
      assert_equal [:admin, 2], @controller.send(:path_args, 2)
    end

    def test_show
      get :show, test_params(id: test_entry.id)
      assert_redirected_to_index
    end

    private

    def test_entry
      countries(:br)
    end

    def test_entry_attrs
      { name: 'United States of America', code: 'US' }
    end

  end
end
