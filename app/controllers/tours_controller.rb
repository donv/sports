class ToursController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @tour_pages, @tours = paginate :tours, :per_page => 10, :order => 'started_at DESC'
  end

  def show
    @tour = Tour.find(params[:id])
  end

  def new
    @tour = Tour.new
  end

  def create
    @tour = Tour.new(params[:tour])
    if @tour.save
      flash[:notice] = 'Tour was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @tour = Tour.find(params[:id])
  end

  def update
    @tour = Tour.find(params[:id])
    if @tour.update_attributes(params[:tour])
      flash[:notice] = 'Tour was successfully updated.'
      redirect_to :action => 'show', :id => @tour
    else
      render :action => 'edit'
    end
  end

  def destroy
    Tour.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
