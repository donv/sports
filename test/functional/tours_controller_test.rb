require 'test_helper'

class ToursControllerTest < ActionController::TestCase
  fixtures :tours

  def setup
    @first_id = tours(:one).id
  end

  def test_index
    skip 'test this later'
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    skip 'test this later'
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:tours)
  end

  def test_show
    skip 'test this later'
    get :show, id: @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:tour)
    assert assigns(:tour).valid?
  end

  def test_new
    skip 'test this later'
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:tour)
  end

  def test_create
    skip 'test this later'
    num_tours = Tour.count

    post :create, tour: {}

    assert_response :redirect
    assert_redirected_to action: :list

    assert_equal num_tours + 1, Tour.count
  end

  def test_edit
    skip 'test this later'
    get :edit, id: @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:tour)
    assert assigns(:tour).valid?
  end

  def test_update
    skip 'test this later'
    post :update, id: @first_id
    assert_response :redirect
    assert_redirected_to action: :show, id: @first_id
  end

  def test_destroy
    skip 'test this later'
    assert_nothing_raised {
      Tour.find(@first_id)
    }

    post :destroy, id: @first_id
    assert_response :redirect
    assert_redirected_to action: :list

    assert_raise(ActiveRecord::RecordNotFound) {
      Tour.find(@first_id)
    }
  end
end
