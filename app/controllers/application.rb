require 'localization'
require "wurfl/wurflhandset"
require "wurfl/wurflutils"

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include Localization
  include WurflUtils

  session :session_key => '_sports_session_id'
  layout 'mwrt002'
  before_filter :login_from_cookie
  
  def initialize *args
    super
    @handsets, @fallbacks = load_wurfl_pstore('lib/wurfl/wurfl.pstore')
  end
  
end
