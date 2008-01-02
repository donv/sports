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
        :title => 'Weight',
        :content => %Q{<a href="#{url_for(:controller => 'weights', :action => :graph, :id => 1, :format => 'png')}">#{image_tag(url_for(:controller => 'weights', :action => :graph_small, :id => 1, :format => 'png'))}</a>},
        :options => {:controller => 'weights'}
      },
      {
        :title => 'Tours',
        :content => %Q{<a href="#{url_for(:controller => 'tours', :action => :graph, :id => 1, :format => 'png')}">#{image_tag(url_for(:controller => 'tours', :action => :graph_small, :id => 1, :format => 'png'))}</a>},
        :options => {:controller => 'tours'}
      },
      {
        :title => 'Browser',
        :content => "<ul><li>#{request.user_agent if request.respond_to? :user_agent}</li>
                         <li>#{@handsets['Mozilla/5.0']}</li>
                         <li>#{@fallbacks['Mozilla/5.0']}</li>
                         <li>#{@handsets.find {|k, v| v.user_agent =~ /Mozilla\/5.0/}}</li>
                         <li>{@fallbacks.find {|k, v| v.user_agent =~ request.user_agent}}</li>
                         <li>#{h(@handsets[@handsets.keys[0]].inspect)}</li>
                         <li>#{h(@fallbacks[@fallbacks.keys[0]].inspect)}</li>
                     </ul>",
      }
    ]
  end
  
end
