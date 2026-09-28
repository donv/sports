# frozen_string_literal: true

require 'test_helper'

class NavigationTest < ActionDispatch::IntegrationTest
  def test_every_page_sends_a_visitor_to_the_login_page_and_remembers_where_they_were
    get sports.weights_path
    assert_redirected_to '/account/login'
    assert_equal sports.weights_path, request.session[:return_to]
    get sports.graph_weights_path
    assert_redirected_to '/account/login'
  end

  def test_remember_me_cookie_logs_the_visitor_in
    user = users(:bob)
    user.remember_me
    cookies[:remember_token] = user.remember_token
    get sports.weights_path
    assert_response :success
  end
end
