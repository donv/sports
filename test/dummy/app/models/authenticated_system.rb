# frozen_string_literal: true

# Stands in for the host application's AuthenticatedSystem, which the engine's controllers include.
# It mirrors only what the engine relies on: a session-based current user, a remember-me cookie,
# and a redirect to the host's login page that remembers where the visitor was.
module AuthenticatedSystem
  def self.included(base)
    base.send :helper_method, :current_user, :logged_in?
  end

  protected

  def logged_in?
    !current_user.nil?
  end

  def current_user
    @current_user ||= session[:user] && User.find_by(id: session[:user])
  end

  def login_required
    logged_in? || access_denied
  end

  def access_denied
    session[:return_to] = request.fullpath
    redirect_to main_app.account_login_path
  end

  def login_from_cookie
    return if logged_in? || cookies[:remember_token].blank?

    user = User.find_by(remember_token: cookies[:remember_token])
    return unless user&.remember_token?

    session[:user] = user.id
    @current_user = user
  end
end
