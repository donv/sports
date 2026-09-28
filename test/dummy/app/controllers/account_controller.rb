# frozen_string_literal: true

# Stands in for the host application's account controller, which the engine redirects to when a
# login is required. The POST endpoint lets integration tests establish a logged-in session.
class AccountController < ApplicationController
  def login
    render plain: 'login'
  end

  def test_login
    session[:user] = params.require(:user_id)
    head :no_content
  end
end
