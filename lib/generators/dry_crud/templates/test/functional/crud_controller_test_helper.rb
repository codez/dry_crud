# A module to include into your functional tests for your crud controller subclasses.
# Simply implement the two methods :test_entry and :test_entry_attrs to test the basic
# crud functionality. Override the test methods if you changed the behaviour in your subclass
# controller.
module CrudControllerTestHelper

  def test_index
    get :index, test_params
    assert_response :success
    assert_template 'index'
    assert_present assigns(:entries)
  end

  def test_index_json
    get :index, test_params(:format => 'json')
    assert_response :success
    assert_present assigns(:entries)
    assert @response.body.starts_with?("[{"), @response.body
  end

  def test_index_search
    field = @controller.search_columns.first
    val = field && test_entry[field].to_s
    return if val.blank?   # does not support search or no value in this field

    get :index, test_params(:q => val[0..((val.size + 1)/ 2)])
    assert_response :success
    assert_present assigns(:entries)
    assert assigns(:entries).include?(test_entry)
  end

  def test_index_sort_asc
    col = model_class.column_names.first
    get :index, test_params(:sort => col, :sort_dir => 'asc')
    assert_response :success
    assert_present assigns(:entries)
    sorted = assigns(:entries).sort_by &(col.to_sym)
    assert_equal sorted, assigns(:entries)
  end

  def test_index_sort_desc
    col = model_class.column_names.first
    get :index, test_params(:sort => col, :sort_dir => 'desc')
    assert_response :success
    assert_present assigns(:entries)
    sorted = assigns(:entries).sort_by &(col.to_sym)
    assert_equal sorted.reverse, assigns(:entries)
  end

  def test_show
    get :show, test_params(:id => test_entry.id)
    assert_response :success
    assert_template 'show'
    assert_equal test_entry, assigns(:entry)
  end

  def test_show_json
    get :show, test_params(:id => test_entry.id, :format => 'json')
    assert_response :success
    assert_equal test_entry, assigns(:entry)
    assert @response.body.starts_with?("{")
  end

  def test_show_with_not_existing_id_raises_RecordNotFound
    assert_raise(ActiveRecord::RecordNotFound) do
      get :show, test_params(:id => 9999)
    end
  end

  def test_show_without_id_redirects_to_index
    assert_raise ActionController::RoutingError, ActiveRecord::RecordNotFound do
      get :show, test_params
    end
  end

  def test_new
    get :new, test_params
    assert_response :success
    assert_template 'new'
    assert assigns(:entry).new_record?
  end

  def test_create
    assert_difference("#{model_class.name}.count") do
      post :create, test_params(model_identifier => test_entry_attrs)
    end
    assert_redirected_to_show assigns(:entry)
    assert ! assigns(:entry).new_record?
    assert_test_attrs_equal
  end

  def test_create_json
    assert_difference("#{model_class.name}.count") do
      post :create, test_params(model_identifier => test_entry_attrs, :format => 'json')
    end
    assert_response :success
    assert @response.body.starts_with?("{")
  end

  def test_edit
    get :edit, test_params(:id => test_entry.id)
    assert_response :success
    assert_template 'edit'
    assert_equal test_entry, assigns(:entry)
  end

  def test_edit_without_id_raises_RecordNotFound
    assert_raise ActionController::RoutingError, ActiveRecord::RecordNotFound do
      get :edit, test_params
    end
  end

  def test_update
    assert_no_difference("#{model_class.name}.count") do
      put :update, test_params(:id => test_entry.id, model_identifier => test_entry_attrs)
    end
    assert_test_attrs_equal
    assert_redirected_to_show assigns(:entry)
  end

  def test_update_json
    assert_no_difference("#{model_class.name}.count") do
      put :update, test_params(:id => test_entry.id, model_identifier => test_entry_attrs, :format => 'json')
    end
    assert_response :success
    assert_equal "", @response.body.strip
  end

  def test_destroy
    assert_difference("#{model_class.name}.count", -1) do
      delete :destroy, test_params(:id => test_entry.id)
    end
    assert_redirected_to_index
  end

  def test_destroy_json
    assert_difference("#{model_class.name}.count", -1) do
      delete :destroy, test_params(:id => test_entry.id, :format => 'json')
    end
    assert_response :success
    assert_equal "", @response.body.strip
  end

  protected

  def assert_redirected_to_index
    assert_redirected_to test_params(:action => 'index', :returning => true)
  end
  
  def assert_redirected_to_show(entry)
    assert_redirected_to test_params(:action => 'show', :id => entry.id)
  end

  def assert_test_attrs_equal
    test_entry_attrs.each do |key, value|
      actual = assigns(:entry).send(key)
      assert_equal value, actual, "#{key} is expected to be <#{value.inspect}>, got <#{actual.inspect}>"
    end
  end

  def model_class
    @controller.model_class
  end

  def model_identifier
    @controller.model_identifier
  end

  # Test object used in several tests
  def test_entry
    raise "Implement this method in your test class"
  end

  # Attribute hash used in several tests
  def test_entry_attrs
    raise "Implement this method in your test class"
  end
  
  def test_params(params = {})
    nesting_params.merge(params)
  end
  
  def nesting_params
    params = {}
    # for nested controllers, add parent ids to each request
    Array(@controller.nesting).collect do |p|
      if p.is_a?(Class) && p < ActiveRecord::Base
        assoc = p.name.underscore
        params["#{assoc}_id"] = test_entry.send(:"#{assoc}_id")
      end
    end
    params
  end

end
