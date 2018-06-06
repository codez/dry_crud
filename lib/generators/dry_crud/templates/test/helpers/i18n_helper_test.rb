require 'test_helper'
require 'support/crud_test_model'
require 'support/crud_test_models_controller'

# Test I18nHelper
class I18nHelperTest < ActionView::TestCase

  include CrudTestHelper

  test 'translate inheritable lookup' do
    # current controller is :crud_test_models, action is :index
    @controller = CrudTestModelsController.new

    I18n.backend.store_translations(
      I18n.locale,
      global: { test_key: 'global' }
    )
    assert_equal 'global', ti(:test_key)

    I18n.backend.store_translations(
      I18n.locale,
      list: { global: { test_key: 'list global' } }
    )
    assert_equal 'list global', ti(:test_key)

    I18n.backend.store_translations(
      I18n.locale,
      list: { index: { test_key: 'list index' } }
    )
    assert_equal 'list index', ti(:test_key)

    I18n.backend.store_translations(
      I18n.locale,
      crud: { global: { test_key: 'crud global' } }
    )
    assert_equal 'crud global', ti(:test_key)

    I18n.backend.store_translations(
      I18n.locale,
      crud: { index: { test_key: 'crud index' } }
    )
    assert_equal 'crud index', ti(:test_key)

    I18n.backend.store_translations(
      I18n.locale,
      crud_test_models: { global: { test_key: 'test global' } }
    )
    assert_equal 'test global', ti(:test_key)

    I18n.backend.store_translations(
      I18n.locale,
      crud_test_models: { index: { test_key: 'test index' } }
    )
    assert_equal 'test index', ti(:test_key)
  end

  test 'translate association lookup' do
    assoc = CrudTestModel.reflect_on_association(:companion)

    I18n.backend.store_translations(
      I18n.locale,
      global: { associations: { test_key: 'global' } }
    )
    assert_equal 'global', ta(:test_key, assoc)

    I18n.backend.store_translations(
      I18n.locale,
      activerecord: {
        associations: {
          crud_test_model: {
            test_key: 'model'
          }
        }
      }
    )
    assert_equal 'model', ta(:test_key, assoc)

    I18n.backend.store_translations(
      I18n.locale,
      activerecord: {
        associations: {
          models: {
            crud_test_model: {
              companion: {
                test_key: 'companion'
              }
            }
          }
        }
      }
    )
    assert_equal 'companion', ta(:test_key, assoc)

    assert_equal 'global', ta(:test_key)
  end

end
