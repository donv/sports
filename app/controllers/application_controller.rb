class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'mwrt002'
  before_filter :populate_layout

  def populate_layout
    @sidebars = [
      {
        :title => 'Weight',
        :content => %Q{<a href="#{url_for(:controller => 'weights', :action => :graph, :id => 1, :format => 'png')}"><img src="#{url_for(:controller => 'weights', :action => :graph_small, :id => 1, :format => 'png')}"/></a>}.html_safe,
        :options => {:controller => 'weights'}
      },
      {
        :title => 'Tours',
        :content => %Q{<a href="#{url_for(:controller => 'tours', :action => :graph, :id => 1, :format => 'png')}"><img src="#{url_for(:controller => 'tours', :action => :graph_small, :id => 1, :format => 'png')}"/></a>}.html_safe,
        :options => {:controller => 'tours'}
      },
    ]
  end

end
