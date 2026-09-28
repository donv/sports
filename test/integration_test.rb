# frozen_string_literal: true

require 'test_helper'

# Every page in the engine requires a login, so tests start out logged in.
class IntegrationTest < ActionDispatch::IntegrationTest
  setup do
    login
  end

  # Log in through the dummy app's test endpoint; the session cannot be written directly.
  def login(user = users(:bob))
    post '/account/test_login', params: { user_id: user.id }
  end
end
