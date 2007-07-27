require File.dirname(__FILE__) + '/../test_helper'
require 'routes_controller'

# Re-raise errors caught by the controller.
class RoutesController; def rescue_action(e) raise e end; end

class RoutesControllerTest < Test::Unit::TestCase
  def setup
    @controller = RoutesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
