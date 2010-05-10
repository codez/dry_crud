
module CrudControllerTestHelper 
    
  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:entries)
    assert_equal 6, assigns(:entries).size
    assert_equal models.sort_by {|a| a.name }, assigns(:entries)
  end
  
  def test_index_xml
    get :index, :format => 'xml'
    assert_response :success
    assert_not_nil assigns(:entries)
    assert @response.body.starts_with?("<?xml")
  end
  
  def test_show
    get :show, :id => test_entry.id
    assert_response :success
    assert_template 'show'  
    assert_equal test_entry, assigns(:entry)
  end
  
  def test_show_xml
    get :show, :id => test_entry.id, :format => 'xml'
    assert_response :success
    assert_equal test_entry, assigns(:entry)
    assert @response.body.starts_with?("<?xml")
  end
  
  def test_show_with_not_existing_id_raises_RecordNotFound
    assert_raise(ActiveRecord::RecordNotFound) do
      get :show, :id => 9999
    end
  end
    
  def test_show_without_id_redirects_to_index
    get :show
    assert_redirected_to_index  
  end
    
  def test_new
    get :new
    assert_response :success
    assert_template 'new'
    assert assigns(:entry).new_record?
  end
  
  def test_create
    assert_difference("#{model_class.name}.count") do
      post :create, model_identifier => test_entry_attrs
    end
    assert_redirected_to assigns(:entry)
    assert ! assigns(:entry).new_record?
    test_entry_attrs.each do |key, value|
      assert_equal value, assigns(:entry).send(key)
    end
  end
  
  def test_create_with_wrong_method_redirects
    get :create, model_identifier => test_entry_attrs
    assert_redirected_to_index
    
    put :create, model_identifier => test_entry_attrs
    assert_redirected_to_index
    
    delete :create, model_identifier => test_entry_attrs
    assert_redirected_to_index
  end
    
  def test_create_xml
    assert_difference("#{model_class.name}.count") do
      post :create, model_identifier => test_entry_attrs, :format => 'xml'
    end
    assert_response :success
    assert @response.body.starts_with?("<?xml")
  end
  
  def test_edit
    get :edit, :id => test_entry.id
    assert_response :success
    assert_template 'edit'
    assert_equal test_entry, assigns(:entry)
  end
  
  def test_edit_without_id_raises_RecordNotFound
    assert_raise(ActiveRecord::RecordNotFound) do
      get :edit
    end
  end
  
  def test_update
    assert_no_difference("#{model_class.name}.count") do
      put :update, :id => test_entry.id, model_identifier => test_entry_attrs
    end
    assert_redirected_to test_entry
    test_entry_attrs.each do |key, value|
      assert_equal value, assigns(:entry).send(key)
    end
  end
    
  def test_update_with_wrong_method_redirects
    get :update, :id => test_entry.id, model_identifier => test_entry_attrs
    assert_redirected_to_index
    
    delete :update, :id => test_entry.id, model_identifier => test_entry_attrs
    assert_redirected_to_index
  end
  
  def test_update_xml
    assert_no_difference("#{model_class.name}.count") do
      put :update, :id => test_entry.id, model_identifier => test_entry_attrs, :format => 'xml'
    end
    assert_response :success
    assert_equal "", @response.body.strip
  end

  def test_delete
    assert_difference("#{model_class.name}.count", -1) do
      delete :destroy, :id => test_entry.id
    end
    assert_redirected_to_index
  end
  
  def test_delete_with_wrong_method
    get :destroy, :id => test_entry.id
    assert_redirected_to_index
    
    put :destroy, :id => test_entry.id
    assert_redirected_to_index
  end
  
  def test_delete_xml
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
  
  # Test object used in several tests
  def test_entry
    raise "Implement this method in your test class"
  end
  
  # Attribute hash used in several tests
  def test_entry_attrs
    raise "Implement this method in your test class"
  end
  
end
