require 'test_helper'

TEST_VIEW_PATH = File.join(Rails.root, 'test', 'test_views')

class RootController < ApplicationController
  include RenderInheritable
  
  attr_accessor :default_template_format
  
  append_view_path(TEST_VIEW_PATH)
  
  def initialize(*args)
    super(*args)
    self.default_template_format = :html
  end
  
  def view_paths
    self.class.view_paths
  end
  
end

class ChildrenController < RootController
  
end

class GrandChildrenController < ChildrenController
  
end

# mock File object
class File
  class << self
    def touched
      @touched ||= []
    end
    
    alias_method :orig_exists?, :exists?
    def exists?(filename, *args)
      touched.include?(filename) || orig_exists?(filename, *args)
    end
    
    def touch_template(file)
      touched << File.join(ActionController::Base.view_paths.first, "#{file}.html.erb")
    end
  end
end

class RenderInheritableTest < ActiveSupport::TestCase
 
  attr_reader :controller, :grand_controller
 
  def setup
    teardown
    @controller = ChildrenController.new
    @grand_controller = GrandChildrenController.new
    ChildrenController.send(:inheritable_cache).clear
    GrandChildrenController.send(:inheritable_cache).clear
  end
  
  def teardown
    FileUtils.rm_rf(TEST_VIEW_PATH)
  end

  test "inheritable_root_controller" do
    assert_equal RootController, RootController.inheritable_root_controller
    assert_equal RootController, ChildrenController.inheritable_root_controller
    assert_equal RootController, GrandChildrenController.inheritable_root_controller
  end

  test "lookup path" do
    assert_equal ['children', 'root'], ChildrenController.send(:inheritance_lookup_path)
    assert_equal ['grand_children', 'children', 'root'], GrandChildrenController.send(:inheritance_lookup_path)
  end
  
  test "inheritable controller finds controller instance" do
    assert_equal 'children', ChildrenController.send(:inheritable_controller)
    assert_equal 'grand_children', GrandChildrenController.send(:inheritable_controller)
  end
    
  test "find non-existing inheritable file" do
    assert_nil @controller.send(:find_inheritable_template_folder, 'foo')
  end
  
  test "find inheritable file not overwritten" do
    touch("root/root.html.erb")
    
    assert_equal 'root', @controller.send(:find_inheritable_template_folder, 'root')
    assert_equal 'root', @grand_controller.send(:find_inheritable_template_folder, 'root')
  end
  
  test "find inheritable file partially overwritten" do
    touch("root/child.html.erb")
    touch("children/child.html.erb")
    
    assert_equal 'children', @controller.send(:find_inheritable_template_folder, 'child')
    assert_equal 'children', @grand_controller.send(:find_inheritable_template_folder, 'child')
  end
  
  test "find inheritable file partially overwritten with gaps" do
    touch("root/grandchild.html.erb")
    touch("grand_children/grandchild.rhtml")
    
    assert_equal 'root', @controller.send(:find_inheritable_template_folder, 'grandchild')
    assert_equal 'grand_children', @grand_controller.send(:find_inheritable_template_folder, 'grandchild')
  end
    
  test "find inheritable file for js format" do
    touch("root/_grandchild.js.rjs")
    touch("grand_children/_grandchild.js.rjs")
       
    assert_equal 'root', @controller.send(:find_inheritable_template_folder, 'grandchild', true)
    assert_equal 'grand_children', @grand_controller.send(:find_inheritable_template_folder, 'grandchild', true)
        
    assert_equal({:js => { true => {'grandchild' => {nil => 'root'}}}}, ChildrenController.send(:inheritable_cache))
    assert_equal({:js => { true => {'grandchild' => {nil => 'grand_children'}}}}, GrandChildrenController.send(:inheritable_cache))
  end
  
  test "find inheritable file for xml format" do
    touch("root/_grandchild.xml.builder")
    touch("grand_children/_grandchild.xml.builder")
    
    assert_equal 'root', @controller.send(:find_inheritable_template_folder, 'grandchild', true)
    assert_equal 'grand_children', @grand_controller.send(:find_inheritable_template_folder, 'grandchild', true)
  end
  
  test "find inheritable file all overwritten" do
    touch("root/all.html.erb")
    touch("children/all.rhtml")
    touch("grand_children/all.html.erb")
    
    assert_equal 'children', @controller.send(:find_inheritable_template_folder, 'all')
    assert_equal 'grand_children', @grand_controller.send(:find_inheritable_template_folder, 'all')
    
    assert_equal({:html => { false => { 'all' => {nil => 'children'}}}}, ChildrenController.send(:inheritable_cache))
    assert_equal({:html => { false => { 'all' => {nil => 'grand_children'}}}}, GrandChildrenController.send(:inheritable_cache))
    
    assert_equal 'children', @controller.send(:find_inheritable_template_folder, 'all')
    assert_equal 'grand_children', @grand_controller.send(:find_inheritable_template_folder, 'all')
    
    assert_equal({:html => { false => { 'all' => {nil => 'children'}}}}, ChildrenController.send(:inheritable_cache))
    assert_equal({:html => { false => { 'all' => {nil => 'grand_children'}}}}, GrandChildrenController.send(:inheritable_cache))    
  end

  private
  
  def touch(file)
    f = File.join(TEST_VIEW_PATH, file)
    FileUtils.mkdir_p(File.dirname(f))
    FileUtils.touch(f)
  end
  
end
