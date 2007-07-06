require 'localization'

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include Localization

  session :session_key => '_sports_session_id'
  layout 'mwrt002'
  before_filter :login_from_cookie
  active_scaffold :tour
end
