# frozen_string_literal: true

require 'test_helper'

class IntegrationTest < ActionDispatch::IntegrationTest
  teardown do
    # get logout_path reply: 'done'
    # assert_equal 'done', response.body
  end

  # def login(login = :admin)
  #   user = users(login)
  #   post '/login/password', params: { user: { login: user.login, password: :atest } }
  #   user
  # end

  # def assert_logged_in
  #   cookies[COOKIE_NAME]
  # end
end
