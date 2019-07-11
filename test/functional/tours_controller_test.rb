# frozen_string_literal: true

require 'integration_test'

module Sports
  class ToursControllerTest < IntegrationTest
    fixtures :tours

    def test_graph
      get Sports::Engine.routes.url_helpers.graph_tours_path
      assert_response :success
    end

    def test_graph_small
      get Sports::Engine.routes.url_helpers.graph_small_tours_path
      assert_response :success
    end
  end
end
