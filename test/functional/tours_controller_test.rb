# frozen_string_literal: true

require 'integration_test'

module Sports
  class ToursControllerTest < IntegrationTest
    include Sports::Engine.routes.url_helpers

    fixtures :tours, :routes

    VALID_TOUR = { started_at: '2026-09-29 18:00', total_time: '01:02:03', distance: 25.5,
                   average_speed: 24.7, max_speed: 41.2, calories: 620, odo: 1234.5, route_id: 1 }.freeze

    def setup
      @first_id = tours(:one).id
    end

    def test_index_lists_tours_with_a_form_and_the_graph
      get tours_path
      assert_response :success
      assert_select 'form[action=?]', tours_path
      assert_select 'tbody tr', Tour.count
      assert_select 'img[src=?]', graph_tours_path(format: :png)
    end

    def test_show
      get tour_path(@first_id)
      assert_response :success
    end

    def test_graph
      get graph_tours_path
      assert_response :success
    end

    def test_graph_small
      get graph_small_tours_path
      assert_response :success
    end

    def test_new
      get new_tour_path
      assert_response :success
      assert_select 'select[name=?]', 'tour[route_id]'
    end

    def test_create
      assert_difference('Tour.count') do
        post tours_path, params: { tour: VALID_TOUR }
      end
      assert_redirected_to tours_path
      tour = Tour.order(:id).last
      assert_equal 25.5, tour.distance
      assert_equal '01:02:03', tour.total_time.strftime('%H:%M:%S')
    end

    def test_create_invalid
      assert_no_difference('Tour.count') do
        post tours_path, params: { tour: VALID_TOUR.merge(distance: -1) }
      end
      assert_response :success
      assert_select '.alert-danger li', /Distance/
    end

    def test_edit
      get edit_tour_path(@first_id)
      assert_response :success
    end

    def test_update
      patch tour_path(@first_id), params: { tour: { distance: 99.9 } }
      assert_redirected_to tour_path(@first_id)
      assert_equal 99.9, tours(:one).reload.distance
    end

    def test_update_invalid
      patch tour_path(@first_id), params: { tour: { distance: -1 } }
      assert_response :success
    end

    def test_destroy
      assert_difference('Tour.count', -1) do
        delete tour_path(@first_id)
      end
      assert_redirected_to tours_path
    end
  end
end
