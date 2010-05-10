require 'test_helper'

class TestModel < ActiveRecord::Base
  default_scope :order => 'name'
  
  def label
    name
  end
end

class TestModelsController < CrudController
  before_create :handle_name
  
  def handle_name
    if @entry.name == 'illegal'
      flash[:error] = "illegal name"
      return false
    end
  end
end

ActionController::Routing::Routes.draw do |map|
  map.resources :test_models
end

class CrudControllerTest < ActionController::TestCase
  
  attr_accessor :models
  
  tests TestModelsController
  
  def setup
    super
    setup_db        
    self.models = []
    models << TestModel.create!(:name => 'aaa', :value => 1)
    models << TestModel.create!(:name => 'bbb', :value => 2)
    models << TestModel.create!(:name => 'ccc', :value => 3)
    models << TestModel.create!(:name => 'abc', :value => 4)
    models << TestModel.create!(:name => 'bca', :value => 5)
    models << TestModel.create!(:name => 'cab', :value => 6)
  end
  
  def teardown
    teardown_db
  end
  
  def setup_db    
    silence_stream(STDOUT) do
      ActiveRecord::Schema.define(:version => 1) do
        create_table :test_models do |t|
          t.column :name, :string
          t.column :value, :float
        end
      end
    end
  end
  
  def teardown_db
    [:test_models].each do |table|            
      ActiveRecord::Base.connection.drop_table(table) rescue nil
    end
  end
  
  test "setup" do
    assert_equal 6, TestModel.count
    assert_equal TestModelsController, @controller.class
    assert_recognizes({:controller => 'test_models', :action => 'index'}, '/test_models')
    assert_recognizes({:controller => 'test_models', :action => 'show', :id => '1'}, '/test_models/1')
  end
  
  test "index" do
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:entries)
    assert_equal 6, assigns(:entries).size
    assert_equal models.sort_by {|a| a.name }, assigns(:entries)
  end
  
  test "index xml" do
    get :index, :format => 'xml'
    assert_response :success
    assert_not_nil assigns(:entries)
    assert @response.body.starts_with?("<?xml")
  end
  
  test "show" do
    get :show, :id => test_entry.id
    assert_response :success
    assert_template 'show'  
    assert_equal test_entry, assigns(:entry)
  end
  
  test "show xml" do
    get :show, :id => test_entry.id, :format => 'xml'
    assert_response :success
    assert_equal test_entry, assigns(:entry)
    assert @response.body.starts_with?("<?xml")
  end
  
  test "show with not existing id raises RecordNotFound" do
    assert_raise(ActiveRecord::RecordNotFound) do
      get :show, :id => 9999
    end
  end
    
  test "show without id redirects to index" do
    get :show
    assert_redirected_to_index  
  end
    
  test "new" do
    get :new
    assert_response :success
    assert_template 'new'
    assert assigns(:entry).new_record?
  end
  
  test "create" do
    assert_difference("#{model_class.name}.count") do
      post :create, model_identifier => test_entry_attrs
    end
    assert_redirected_to assigns(:entry)
    assert ! assigns(:entry).new_record?
    test_entry_attrs.each do |key, value|
      assert_equal value, assigns(:entry).send(key)
    end
  end
  
  test "create with wrong method redirects" do
    get :create, model_identifier => test_entry_attrs
    assert_redirected_to_index
    
    put :create, model_identifier => test_entry_attrs
    assert_redirected_to_index
    
    delete :create, model_identifier => test_entry_attrs
    assert_redirected_to_index
  end
    
  test "create xml" do
    assert_difference("#{model_class.name}.count") do
      post :create, model_identifier => test_entry_attrs, :format => 'xml'
    end
    assert_response :success
    assert @response.body.starts_with?("<?xml")
  end
  
  test "create with before callback" do
    assert_no_difference("#{model_class.name}.count") do
      post :create, :test_model => {:name => 'illegal', :value => 2}
    end
    assert_template 'new'
    assert assigns(:entry).new_record?
    assert flash[:error].present?
    assert_equal 'illegal', assigns(:entry).name
  end
  
  test "edit" do
    get :edit, :id => test_entry.id
    assert_response :success
    assert_template 'edit'
    assert_equal test_entry, assigns(:entry)
  end
  
  test "edit without id raises RecordNotFound" do
    assert_raise(ActiveRecord::RecordNotFound) do
      get :edit
    end
  end
  
  test "update" do
    assert_no_difference("#{model_class.name}.count") do
      put :update, :id => test_entry.id, model_identifier => test_entry_attrs
    end
    assert_redirected_to test_entry
    test_entry_attrs.each do |key, value|
      assert_equal value, assigns(:entry).send(key)
    end
  end
    
  test "update with wrong method redirects" do
    get :update, :id => test_entry.id, model_identifier => test_entry_attrs
    assert_redirected_to_index
    
    delete :update, :id => test_entry.id, model_identifier => test_entry_attrs
    assert_redirected_to_index
  end
  
  test "update xml" do
    assert_no_difference("#{model_class.name}.count") do
      put :update, :id => test_entry.id, model_identifier => test_entry_attrs, :format => 'xml'
    end
    assert_response :success
    assert_equal "", @response.body.strip
  end

  test "delete" do
    assert_difference("#{model_class.name}.count", -1) do
      delete :destroy, :id => test_entry.id
    end
    assert_redirected_to_index
  end
  
  test "delete with wrong method" do
    get :destroy, :id => test_entry.id
    assert_redirected_to_index
    
    put :destroy, :id => test_entry.id
    assert_redirected_to_index
  end
  
  test "delete xml" do
    assert_difference("#{model_class.name}.count", -1) do
      delete :destroy, :id => test_entry.id, :format => 'xml'
    end
    assert_response :success
    assert_equal "", @response.body.strip
  end
  
  protected 
  
  def assert_redirected_to_index
    assert_redirected_to :action => 'index'
  end
  
  def model_class
    @controller.controller_name.classify.constantize
  end
  
  def model_identifier
    @controller.controller_name.singularize.to_sym
  end
  
  def test_entry
    models[0]
  end
  
  def test_entry_attrs
    {:name => 'foo', :value => 2}
  end
  
end
