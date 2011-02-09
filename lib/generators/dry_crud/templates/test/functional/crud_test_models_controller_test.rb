require 'test_helper'
require 'crud_test_model'
require File.join(File.dirname(__FILE__), 'crud_controller_test_helper')

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
    assert_recognizes({:controller => 'crud_test_models', :action => 'index'}, '/crud_test_models')
    assert_recognizes({:controller => 'crud_test_models', :action => 'show', :id => '1'}, '/crud_test_models/1')
    # no need to hide actions for pure restful controllers
    #assert_equal %w(index show new create edit update destroy).to_set, CrudTestModelsController.send(:action_methods)
  end
  
  def test_index
    super
    assert_equal 6, assigns(:entries).size
    assert_equal assigns(:entries).sort_by(&:name), assigns(:entries)
    assert_equal Hash.new, session[:list_params]
  end
  
  def test_index_search
  	super
  	assert_equal 1, assigns(:entries).size
    assert_equal({:q => 'AAAA'}, session[:list_params]['/crud_test_models'])
  end
  
  def test_index_with_custom_options
    get :index, :filter => true
    assert_response :success
    assert_template 'index'
    assert_present assigns(:entries)
    assert_equal 2, assigns(:entries).size
    assert_equal assigns(:entries).sort_by(&:children).reverse, assigns(:entries)
  end
    
  def test_index_search_with_custom_options
    get :index, :q => 'DDD', :filter => true
    assert_response :success
    assert_template 'index'
    assert_present assigns(:entries)
    assert_equal 1, assigns(:entries).size
    assert_equal [CrudTestModel.find_by_name('BBBBB')], assigns(:entries)
    assert_equal({:q => 'DDD'}, session[:list_params]['/crud_test_models'])
  end
  
  def test_sort_given_column
  	get :index, :sort => 'children', :sort_dir => 'asc'
    assert_response :success
    assert_template 'index'
    assert_present assigns(:entries)
    assert_equal 6, assigns(:entries).size
    assert_equal CrudTestModel.all.sort_by(&:children), assigns(:entries)
    assert_equal({:sort => 'children', :sort_dir => 'asc'}, session[:list_params]['/crud_test_models'])
  end
  
  def test_sort_virtual_column
    get :index, :sort => 'chatty', :sort_dir => 'desc'
    assert_response :success
    assert_template 'index'
    assert_present assigns(:entries)
    assert_equal 6, assigns(:entries).size
    assert_equal({:sort => 'chatty', :sort_dir => 'desc'}, session[:list_params]['/crud_test_models'])
    
    sorted = CrudTestModel.all.sort_by(&:chatty)
    
    # sort order is ambiguous, use index    
    names = assigns(:entries).collect(&:name)
    assert names.index('BBBBB') < names.index('AAAAA')
    assert names.index('BBBBB') < names.index('DDDDD')
    assert names.index('EEEEE') < names.index('AAAAA')
    assert names.index('EEEEE') < names.index('DDDDD')
    assert names.index('AAAAA') < names.index('CCCCC')
    assert names.index('AAAAA') < names.index('FFFFF')
    assert names.index('DDDDD') < names.index('CCCCC')
    assert names.index('DDDDD') < names.index('FFFFF')
  end
  
  def test_sort_with_search
    get :index, :q => 'DDD', :sort => 'chatty', :sort_dir => 'asc'
    assert_response :success
    assert_template 'index'
    assert_present assigns(:entries)
    assert_equal 3, assigns(:entries).size
    assert_equal ['CCCCC', 'DDDDD', 'BBBBB'], assigns(:entries).collect(&:name)
    assert_equal({:sort => 'chatty', :sort_dir => 'asc', :q => 'DDD'}, session[:list_params]['/crud_test_models'])
  end
  
  def test_index_returning
    session[:list_params] = {}
    session[:list_params]['/crud_test_models'] = {:q => 'DDD', :sort => 'chatty', :sort_dir => 'desc'}
    get :index, :returning => true
    assert_response :success
    assert_template 'index'
    assert_present assigns(:entries)
    assert_equal 3, assigns(:entries).size
    assert_equal ['BBBBB', 'DDDDD', 'CCCCC'], assigns(:entries).collect(&:name)
    assert_equal 'DDD', @controller.params[:q]
    assert_equal 'chatty', @controller.params[:sort]
    assert_equal 'desc', @controller.params[:sort_dir]
  end
  
  def test_new
    super
    assert assigns(:companions)
    assert_equal [:before_render_new, :before_render_form], @controller.called_callbacks
  end
  
  def test_create
    super
    assert_equal [:before_create, :before_save, :after_save, :after_create], @controller.called_callbacks
  end
  
  def test_edit
  	super
    assert_equal [:before_render_edit, :before_render_form], @controller.called_callbacks
  end
  
  def test_update
    super
    assert_equal [:before_update, :before_save, :after_save, :after_update], @controller.called_callbacks
  end
  
  def test_destroy
    super
    assert_equal [:before_destroy, :after_destroy], @controller.called_callbacks
  end
  
  def test_create_with_before_callback
    assert_no_difference("#{model_class.name}.count") do
      post :create, :crud_test_model => {:name => 'illegal', :children => 2}
    end
    assert_template 'new'
    assert assigns(:entry).new_record?
    assert assigns(:companions)
    assert flash[:error].present?
    assert_equal 'illegal', assigns(:entry).name
    assert_equal [:before_render_new, :before_render_form], @controller.called_callbacks
  end
    
  def test_create_with_before_callback_redirect
    @controller.should_redirect = true
    assert_no_difference("#{model_class.name}.count") do
      post :create, :crud_test_model => {:name => 'illegal', :children => 2}
    end
    assert_redirected_to :action => 'index'
    assert_nil @controller.called_callbacks
  end
  
  def test_new_with_before_render_callback_redirect_does_not_set_companions
    @controller.should_redirect = true
    get :new
    assert_redirected_to :action => 'index'
    assert_nil assigns(:companions)
  end
  
  protected 
  
  def special_routing
    @routes = ActionDispatch::Routing::RouteSet.new
    _routes = @routes
    
    @controller.singleton_class.send(:include, _routes.url_helpers)
    @controller.view_context_class = Class.new(@controller.view_context_class) do
      include _routes.url_helpers
    end
    
    @routes.draw { resources :crud_test_models }
  end
  
  def test_entry
    crud_test_models(:AAAAA)
  end
  
  def test_entry_attrs
    {:name => 'foo', 
     :children => 42, 
     :companion_id => 3,
     :rating => 8.5, 
     :income => 2.42, 
     :birthdate => '31-12-1999'.to_date,
     :human => true,
     :remarks => "some custom\n\tremarks"}
  end
  
end
