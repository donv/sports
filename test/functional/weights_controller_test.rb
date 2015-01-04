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
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:weight)
    assert assigns(:weight).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:weight)
  end

  def test_create
    num_weights = Weight.count

    post :create, :weight => {:weight => 109.9}

    assert_response :redirect
    assert_redirected_to :action => :graph, :format => :png

    assert_equal num_weights + 1, Weight.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:weight)
    assert assigns(:weight).valid?
  end

  def test_update
    post :update, id: @first_id, weight: {weight: 99.9}
    assert_response :redirect
    assert_redirected_to action: :show, id: @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Weight.find(@first_id)
    }

    post :destroy, id: @first_id
    assert_response :redirect
    assert_redirected_to action: :index

    assert_raise(ActiveRecord::RecordNotFound) {
      Weight.find(@first_id)
    }
  end
end
