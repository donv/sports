require 'test_helper'

class WeightsControllerTest < ActionController::TestCase
  fixtures :weights

  def setup
    @first_id = weights(:one).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template :index
  end

  def test_show
    get :show, params: {id: @first_id}

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:weight)
    assert assigns(:weight).valid?
  end

  def test_graph_small
    get :graph_small
    assert_response :success
  end

  def test_graph
    get :graph
    assert_response :success
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:weight)
  end

  def test_create
    assert_difference 'Weight.count' do
      post :create, params: {weight: { weight: 109.9 }}
    end

    assert_response :redirect
    assert_redirected_to action: :graph, format: :png
  end

  def test_create_invalid
    assert_no_difference('Weight.count') { post :create, params: {weight: { weight: 49.9 } }}
    assert_response :success
    assert_template :new
  end

  def test_edit
    get :edit, params: {id: @first_id}

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:weight)
    assert assigns(:weight).valid?
  end

  def test_update
    post :update, params: {id: @first_id, weight: { weight: 99.9 }}
    assert_response :redirect
    assert_redirected_to action: :show, id: @first_id
  end

  def test_update_invalid
    post :update, params: {id: @first_id, weight: { weight: 49.9 }}
    assert_response :success
    assert_template :edit
  end

  def test_destroy
    assert_nothing_raised {
      Weight.find(@first_id)
    }

    post :destroy, params: {id: @first_id}
    assert_response :redirect
    assert_redirected_to action: :index

    assert_raise(ActiveRecord::RecordNotFound) {
      Weight.find(@first_id)
    }
  end
end
