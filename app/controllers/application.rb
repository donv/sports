require 'localization'
require "wurfl/wurflhandset"
require "wurfl/wurflutils"

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include Localization
  include WurflUtils
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper

  session :session_key => '_sports_session_id'
  layout 'mwrt002'
  before_filter :login_from_cookie
  before_filter :populate_layout
  
  def initialize *args
    super
    @handsets, @fallbacks = load_wurfl_pstore('lib/wurfl/wurfl.pstore')
  end

  def populate_layout
    @sidebars = [
      {
        :title => 'Tours',
        :content => image_tag(url_for(:controller => 'tours', :action => :graph_small, :id => 1, :format => 'png')),
        :options => {:controller => 'tours', :action => :graph, :id => 1, :format => 'png'}
      }
    ]
  end
  
end
