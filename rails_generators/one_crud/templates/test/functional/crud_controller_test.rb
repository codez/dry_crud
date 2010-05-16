require 'test_helper'
require File.join(File.dirname(__FILE__), 'crud_controller_test_helper')

class TestModel < ActiveRecord::Base #:nodoc:
  default_scope :order => 'name'
  
  def label
    name
  end
end

class TestModelsController < CrudController #:nodoc:
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
  
  include CrudControllerTestHelper
  
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
        ActiveRecord::Base.connection.create_table :test_models do |t|
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
  
  def test_setup
    assert_equal 6, TestModel.count
    assert_equal TestModelsController, @controller.class
    assert_recognizes({:controller => 'test_models', :action => 'index'}, '/test_models')
    assert_recognizes({:controller => 'test_models', :action => 'show', :id => '1'}, '/test_models/1')
  end
  
  def test_index
    super
    assert_equal 6, assigns(:entries).size
    assert_equal models.sort_by {|a| a.name }, assigns(:entries)
  end
  
  def test_create_with_before_callback
    assert_no_difference("#{model_class.name}.count") do
      post :create, :test_model => {:name => 'illegal', :value => 2}
    end
    assert_template 'new'
    assert assigns(:entry).new_record?
    assert flash[:error].present?
    assert_equal 'illegal', assigns(:entry).name
  end
  
  protected 
  
  def test_entry
    models[0]
  end
  
  def test_entry_attrs
    {:name => 'foo', :value => 2}
  end
  
end
