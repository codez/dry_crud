require 'test_helper'

class CrudControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cruds)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create crud" do
    assert_difference('Crud.count') do
      post :create, :crud => { }
    end

    assert_redirected_to crud_path(assigns(:crud))
  end

  test "should show crud" do
    get :show, :id => cruds(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => cruds(:one).to_param
    assert_response :success
  end

  test "should update crud" do
    put :update, :id => cruds(:one).to_param, :crud => { }
    assert_redirected_to crud_path(assigns(:crud))
  end

  test "should destroy crud" do
    assert_difference('Crud.count', -1) do
      delete :destroy, :id => cruds(:one).to_param
    end

    assert_redirected_to cruds_path
  end
end
