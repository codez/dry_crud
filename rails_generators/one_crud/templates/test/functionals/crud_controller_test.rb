require 'test_helper'
require 'authlogic/test_case'

# AR keeps printing annoying schema statements
#$stdout = StringIO.new

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
    
    setup :activate_authlogic
    
    tests TestModelsController


    def setup
        super
        setup_db        
        login_as('root')
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
        ActiveRecord::Schema.define(:version => 1) do
            create_table :test_models do |t|
                t.column :name, :string
                t.column :value, :float
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
    end
        
    test "index" do
        get :index
        assert_response :success
        assert_template 'index'
        assert_equal 6, assigns(:entries).size
        assert_equal models.sort {|a,b| a.name <=> b.name }, assigns(:entries)
    end
    
    test "show" do
        get :show, :id => models[0].id
        assert_response :success
        assert_template 'show'  
        assert_equal models[0], assigns(:entry)
    end
    
    test "show without id" do
        assert_raise(ActiveRecord::RecordNotFound) do
            get :show
        end
    end
            
    test "edit" do
        get :edit, :id => models[0].id
        assert_response :success
        assert_template 'edit'
        assert_equal models[0], assigns(:entry)
    end
       
    test "edit without id" do
        assert_raise(ActiveRecord::RecordNotFound) do
            get :edit
        end
    end
    
    test "update" do
        assert_no_difference('TestModel.count') do
            post :update, :id => models[0].id, :entry => {:name => 'gugu', :value => 2}
        end
        assert_redirected_to :controller => :test_models, :action => 'show', :id => models[0].id
        assert_equal 'gugu', assigns(:entry).name
    end
                  
    test "new" do
        get :new
        assert_response :success
        assert_template 'new'
        assert assigns(:entry).new_record?
    end
    
    test "create" do
        assert_difference('TestModel.count') do
            post :create, :entry => {:name => 'gugu', :value => 2}
        end
        assert_redirected_to :controller => :test_models, :action => 'show', :id => assigns(:entry).id
        assert ! assigns(:entry).new_record?
        assert_equal 'gugu', assigns(:entry).name
    end
                      
    test "before create callback" do
        assert_no_difference('TestModel.count') do
            post :create, :entry => {:name => 'illegal', :value => 2}
        end
        assert_template 'new'
        assert assigns(:entry).new_record?
        assert flash[:error].present?
        assert_equal 'illegal', assigns(:entry).name
    end
    
    test "delete" do
        assert_difference('TestModel.count', -1) do
            post :destroy, :id => models[0].id
        end
        assert_redirected_to :controller => :test_models, :action => 'index'
    end
end
