require 'test_helper'

class ToursControllerTest < ActionController::TestCase
  fixtures :tours

  def test_graph
    get :graph
    assert_response :success
  end

  def test_graph_small
    get :graph_small
    assert_response :success
  end
end
