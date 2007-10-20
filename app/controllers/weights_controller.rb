class WeightsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @weight_pages, @weights = paginate :weights, :per_page => 10, :order => 'created_at DESC'
  end

  def show
    @weight = Weight.find(params[:id])
  end

  def new
    @weight = Weight.new
  end

  def create
    @weight = Weight.new(params[:weight])
    if @weight.save
      flash[:notice] = 'Weight was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @weight = Weight.find(params[:id])
  end

  def update
    @weight = Weight.find(params[:id])
    if @weight.update_attributes(params[:weight])
      flash[:notice] = 'Weight was successfully updated.'
      redirect_to :action => 'show', :id => @weight
    else
      render :action => 'edit'
    end
  end

  def destroy
    Weight.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def graph_small
    graph 160
  end
  
  def graph(size = 640)
    g = Gruff::Line.new(size)
    g.theme_37signals
    g.title = l(:chart)
    g.font = '/usr/share/fonts/bitstream-vera/Vera.ttf'
    g.legend_font_size = 14
    g.hide_dots = true
    #g.colors = %w{blue orange green grey grey lightblue #d7a790}
    
    weights = Weight.find(:all, :order => :created_at)
    
    g.data(l(:weight), weights.map {|t| t.weight})
    
    #g.minimum_value = 0
    
    labels = {}
    weights.each_with_index do |t, i|
      labels[i] = t.created_at.strftime('%y-%m-%d')
    end
    g.labels = labels
    
    # g.draw_vertical_legend
    
    g.maximum_value = g.maximum_value.to_i
    
    send_data(g.to_blob,
              :disposition => 'inline', 
    :type => 'image/png', 
    :filename => "weights_chart.png")
  end
  
end
