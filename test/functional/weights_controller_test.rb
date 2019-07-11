require 'integration_test'

module Sports
  class WeightsControllerTest < IntegrationTest
    include Sports::Engine.routes.url_helpers

    fixtures :weights

    def setup
      @first_id = weights(:one).id
    end

    def test_index
      get weights_path
      assert_response :success
      assert_template :index
    end

    def test_show
      get weight_path(@first_id)

      assert_response :success

      assert_not_nil assigns(:weight)
      assert assigns(:weight).valid?
    end

    def test_graph_small
      get graph_small_weights_path
      assert_response :success
    end

    def test_graph
      get graph_weights_path
      assert_response :success
    end

    def test_new
      get new_weight_path

      assert_response :success
      assert_template 'new'

      assert_not_nil assigns(:weight)
    end

    def test_create
      assert_difference 'Weight.count' do
        post weights_path, params: { weight: { weight: 109.9 } }
      end

      assert_response :redirect
      assert_redirected_to action: :graph, format: :png
    end

    def test_create_invalid
      assert_no_difference('Weight.count') { post weights_path, params: { weight: { weight: 49.9 } } }
      assert_response :success
      assert_template :new
    end

    def test_edit
      get edit_weight_path(@first_id)

      assert_response :success
      assert_template 'edit'

      assert_not_nil assigns(:weight)
      assert assigns(:weight).valid?
    end

    def test_update
      patch weight_path(@first_id), params: { weight: { weight: 99.9 } }
      assert_response :redirect
      assert_redirected_to action: :show, id: @first_id
    end

    def test_update_invalid
      patch weight_path(@first_id), params: { weight: { weight: 49.9 } }
      assert_response :success
      assert_template :edit
    end

    def test_destroy
      assert_nothing_raised { Weight.find(@first_id) }

      delete weight_path(@first_id)
      assert_response :redirect
      assert_redirected_to action: :index

      assert_raise(ActiveRecord::RecordNotFound) { Weight.find(@first_id) }
    end
  end
end
