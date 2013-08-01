class WeightsController < ApplicationController
  def index
    @weights = Weight.paginate :page => params[:page], :per_page => 10, :order => 'created_at DESC'
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
      redirect_to :action => :graph, :format => :png
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
    redirect_to :action => 'index'
  end

  def graph_small
    graph 160
  end

  def graph(size = 640)
    weights = Weight.all(:order => :created_at)

    g = Gruff::Line.new(size)
    g.title = t(:weight).capitalize
    g.hide_legend = true
    g.hide_dots = true if weights.size > 25

    g.dataxy(t(:weight), weights.map { |t| t.created_at.to_i }, weights.map { |t| t.weight })

    g.minimum_value = g.minimum_value.to_i

    labels = {}
    weights.each do |w|
      labels[w.created_at.to_date.midnight.to_i] = w.created_at.strftime('%Y-%m-%d')
    end
    g.labels = labels

    send_data(g.to_blob, :disposition => 'inline', :type => 'image/png',
              :filename => 'weights_chart.png')
  end

end
