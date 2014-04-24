# encoding: UTF-8
require 'test_helper'
require 'support/crud_test_helper'
require 'support/crud_test_model'
require 'support/crud_controller_test_helper'

# Tests all actions of the CrudController based on a dummy model
# (CrudTestModel). This is useful to test the general behavior
# of CrudController.
class CrudTestModelsControllerTest < ActionController::TestCase

  include CrudControllerTestHelper
  include CrudTestHelper

  attr_accessor :models

  setup :reset_db, :setup_db, :create_test_data, :special_routing

  teardown :reset_db

  def test_setup
    assert_equal 6, CrudTestModel.count
    assert_equal CrudTestModelsController, @controller.class
    assert_recognizes({ controller: 'crud_test_models',
                        action: 'index' },
                      '/crud_test_models')
    assert_recognizes({ controller: 'crud_test_models',
                        action: 'show',
                        id: '1' },
                      '/crud_test_models/1')
  end

  def test_index
    super
    assert_equal 6, entries.size
    assert_equal entries.sort_by(&:name), entries
    assert_equal({}, session[:list_params])
    assert_equal entries, assigns(:crud_test_models)
    assert_respond_to assigns(:crud_test_models), :klass
  end

  def test_index_js
    xhr :get, :index, test_params
    assert_response :success
    assert_equal 'index js', @response.body
    assert entries.present?
  end

  def test_index_search
    super
    assert_equal 1, entries.size
    assert_equal({ q: 'AAAA' }, session[:list_params]['/crud_test_models'])
  end

  def test_index_with_custom_options
    get :index, filter: true
    assert_response :success
    assert_template 'index'
    assert entries.present?
    assert_equal 2, entries.size
    assert_equal entries.sort_by(&:children).reverse, entries
  end

  def test_index_search_with_custom_options
    get :index, q: 'DDD', filter: true
    assert_response :success
    assert_template 'index'
    assert entries.present?
    assert_equal 1, entries.size
    assert_equal [CrudTestModel.find_by_name('BBBBB')], entries
    assert_equal({ q: 'DDD' }, session[:list_params]['/crud_test_models'])
  end

  def test_sort_given_column
    get :index, sort: 'children', sort_dir: 'asc'
    assert_response :success
    assert_template 'index'
    assert entries.present?
    assert_equal 6, entries.size
    assert_equal CrudTestModel.all.sort_by(&:children), entries
    assert_equal({ sort: 'children', sort_dir: 'asc' },
                 session[:list_params]['/crud_test_models'])
  end

  def test_sort_virtual_column
    get :index, sort: 'chatty', sort_dir: 'desc'
    assert_response :success
    assert_template 'index'
    assert entries.present?
    assert_equal 6, entries.size
    assert_equal({ sort: 'chatty', sort_dir: 'desc' },
                 session[:list_params]['/crud_test_models'])

    # sort order is ambiguous, use index
    names = entries.map(&:name)
    assert names.index('BBBBB') < names.index('AAAAA')
    assert names.index('BBBBB') < names.index('DDDDD')
    assert names.index('EEEEE') < names.index('AAAAA')
    assert names.index('EEEEE') < names.index('DDDDD')
    assert names.index('AAAAA') < names.index('CCCCC')
    assert names.index('DDDDD') < names.index('CCCCC')
  end

  def test_sort_with_search
    get :index, q: 'DDD', sort: 'chatty', sort_dir: 'asc'
    assert_response :success
    assert_template 'index'
    assert entries.present?
    assert_equal 3, entries.size
    assert_equal %w(CCCCC DDDDD BBBBB), entries.map(&:name)
    assert_equal({ sort: 'chatty', sort_dir: 'asc', q: 'DDD' },
                 session[:list_params]['/crud_test_models'])
  end

  def test_index_returning
    session[:list_params] = {}
    session[:list_params]['/crud_test_models'] = { q: 'DDD',
                                                   sort: 'chatty',
                                                   sort_dir: 'desc' }
    get :index, returning: true
    assert_response :success
    assert_template 'index'
    assert entries.present?
    assert_equal 3, entries.size
    assert_equal %w(BBBBB DDDDD CCCCC), entries.map(&:name)
    assert_equal 'DDD', @controller.params[:q]
    assert_equal 'chatty', @controller.params[:sort]
    assert_equal 'desc', @controller.params[:sort_dir]
  end

  def test_new
    super
    assert assigns(:companions)
    assert_equal @controller.send(:entry), assigns(:crud_test_model)
    assert_equal [:before_render_new, :before_render_form],
                 @controller.called_callbacks
  end

  def test_show
    super
    assert_equal @controller.send(:entry), assigns(:crud_test_model)
  end

  def test_show_with_custom
    get :show, test_params(id: crud_test_models(:BBBBB).id)
    assert_response :success
    assert_equal 'custom html', @response.body
  end

  def test_create
    super
    assert_match /model got created/, flash[:notice]
    assert flash[:alert].blank?
    assert_equal [:before_create, :before_save, :after_save, :after_create],
                 @controller.called_callbacks
  end

  def test_edit
    super
    assert_equal @controller.send(:entry), assigns(:crud_test_model)
    assert_equal [:before_render_edit, :before_render_form],
                 @controller.called_callbacks
  end

  def test_update
    super
    assert_equal I18n.t('crud.update.flash.success',
                        model: 'Crud Test Model <i>foo</i>'),
                 flash[:notice]
    assert flash[:alert].blank?
    assert_equal @controller.send(:entry), assigns(:crud_test_model)
    assert_equal [:before_update, :before_save, :after_save, :after_update],
                 @controller.called_callbacks
  end

  def test_destroy
    super
    assert_equal [:before_destroy, :after_destroy],
                 @controller.called_callbacks
    assert_equal I18n.t('crud.destroy.flash.success',
                         model: 'Crud Test Model <i>AAAAA</i>'),
                 flash[:notice]
  end

  def test_create_with_before_callback
    assert_no_difference('CrudTestModel.count') do
      post :create, crud_test_model: { name: 'illegal', children: 2 }
    end
    assert_response :success
    assert_template 'new'
    assert entry.new_record?
    assert assigns(:companions).present?
    assert flash[:alert].present?
    assert_equal 'illegal', entry.name
    assert_equal [:before_render_new, :before_render_form],
                 @controller.called_callbacks
  end

  def test_create_with_before_callback_redirect
    @controller.should_redirect = true
    assert_no_difference('CrudTestModel.count') do
      post :create, crud_test_model: { name: 'illegal', children: 2 }
    end
    assert_redirected_to action: 'index'
    assert_nil @controller.called_callbacks
  end

  def test_new_with_before_render_callback_redirect_does_not_set_companions
    @controller.should_redirect = true
    get :new
    assert_redirected_to action: 'index'
    assert_nil assigns(:companions)
  end

  def test_create_with_failure
    assert_no_difference('CrudTestModel.count') do
      post :create, crud_test_model: { children: 2 }
    end
    assert_response :success
    assert_template 'new'
    assert entry.new_record?
    assert assigns(:companions)
    assert flash[:notice].blank?, flash[:notice].to_s
    assert flash[:alert].blank?, flash[:alert].to_s
    assert entry.name.blank?
    assert_equal [:before_create, :before_save,
                  :before_render_new, :before_render_form],
                 @controller.called_callbacks
  end

  def test_create_with_failure_json
    assert_no_difference('CrudTestModel.count') do
      post :create, crud_test_model: { children: 2 }, format: 'json'
    end
    assert_response :unprocessable_entity
    assert entry.new_record?
    assert_match /errors/, @response.body
    assert_equal [:before_create, :before_save], @controller.called_callbacks
  end

  def test_update_with_failure
    put :update, id: test_entry.id, crud_test_model: { rating: 20 }
    assert_response :success
    assert_template 'edit'
    assert entry.changed?
    assert flash[:notice].blank?
    assert flash[:alert].blank?
    assert_equal 20, entry.rating
    assert_equal [:before_update, :before_save,
                  :before_render_edit, :before_render_form],
                 @controller.called_callbacks
  end

  def test_update_with_failure_json
    put :update, id: test_entry.id,
                 crud_test_model: { rating: 20 },
                 format: 'json'
    assert_response :unprocessable_entity
    assert entry.changed?
    assert_match /errors/, @response.body
    assert flash[:notice].blank?
    assert_equal 20, entry.rating
    assert_equal [:before_update, :before_save], @controller.called_callbacks
  end

  def test_destroy_failure
    assert_no_difference("#{model_class.name}.count") do
      @request.env['HTTP_REFERER'] =
        crud_test_model_url(crud_test_models(:BBBBB))
      delete :destroy, test_params(id: crud_test_models(:BBBBB).id)
    end
    assert_redirected_to_show(entry)
    assert_match /companion/, flash[:alert]
    assert flash[:notice].blank?
  end

  def test_destroy_failure_callback
    e = crud_test_models(:AAAAA)
    e.update_attribute :name, 'illegal'
    assert_no_difference("#{model_class.name}.count") do
      delete :destroy, test_params(id: e.id)
    end
    assert_redirected_to_index
    assert_match /illegal name/, flash[:alert]
    assert flash[:notice].blank?
  end

  def test_destroy_failure_json
    assert_no_difference("#{model_class.name}.count") do
      delete :destroy, test_params(id: crud_test_models(:BBBBB).id,
                                   format: 'json')
    end
    assert_response :unprocessable_entity
    assert_match /errors/, @response.body
    assert flash[:notice].blank?
  end

  def test_models_label
    assert_equal 'Crud Test Models', @controller.models_label
    assert_equal 'Crud Test Model', @controller.models_label(false)
  end

  private

  def test_entry
    crud_test_models(:AAAAA)
  end

  def new_entry_attrs
    { name: 'foo',
      children: 42,
      companion_id: 3,
      rating: 8.5,
      income: 2.42,
      birthdate: '31-12-1999'.to_date,
      human: true,
      remarks: "some custom\n\tremarks" }
  end

  def edit_entry_attrs
    { name: 'foo',
      children: 42,
      rating: 8.5,
      income: 2.42,
      birthdate: '31-12-1999'.to_date,
      human: true,
      remarks: "some custom\n\tremarks" }
  end
end
