require 'gruff'

class ToursController < ApplicationController
  def graph_small
    graph 160
  end
  
  def graph(size = 640)
    g = Gruff::Line.new(size)
    g.theme_37signals
    g.title = t(:chart)
    g.font = '/usr/share/fonts/bitstream-vera/Vera.ttf'
    g.legend_font_size = 14
    g.hide_dots = true
    #g.colors = %w{blue orange green grey grey lightblue #d7a790}
    
    tours = Tour.all(:order => :started_at)
    
    g.data(t(:time), tours.map {|t| t.total_time.min + t.total_time.sec / 60})
    g.data(t(:distance), tours.map {|t| t.distance})
    
    g.minimum_value = 0
    
    labels = {}
    tours.each_with_index do |t, i|
      labels[i] = t.started_at.strftime('%y-%m-%d')
    end
    g.labels = labels
    
    # g.draw_vertical_legend
    
    g.maximum_value = g.maximum_value.to_i
    
    send_data(g.to_blob,
              :disposition => 'inline', 
    :type => 'image/png', 
    :filename => 'tours_chart.png')
  end
  
end
