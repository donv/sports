# frozen_string_literal: true

module Sports
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    # Provided by the host application, which owns authentication.
    include AuthenticatedSystem

    before_action :login_from_cookie
    before_action :login_required
  end
end
