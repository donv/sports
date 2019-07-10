require 'gruff'

module Sports
  class WeightsController < ApplicationController
    def index
      @weights = Weight.order('created_at DESC')
    end

    def show
      @weight = Weight.find(params[:id])
    end

    def new
      @weight = Weight.new
    end

    def create
      @weight = Weight.new(weight_params)
      if @weight.save
        flash[:notice] = 'Weight was successfully created.'
        redirect_to action: :graph, format: :png
      else
        render action: :new
      end
    end

    def edit
      @weight = Weight.find(params[:id])
    end

    def update
      @weight = Weight.find(params[:id])
      if @weight.update_attributes(weight_params)
        flash[:notice] = 'Weight was successfully updated.'
        redirect_to action: :show, id: @weight
      else
        render action: :edit
      end
    end

    def destroy
      Weight.find(params[:id]).destroy
      redirect_to action: :index
    end

    def graph_small
      graph 160
    end

    def graph(size = 640)
      weights = Weight.order(:created_at).to_a

      g = Gruff::Line.new(size)
      g.title = t(:weight).capitalize
      g.hide_legend = true
      g.hide_dots = true if weights.size > 25
      g.baseline_value = 100

      g.dataxy(t(:weight), weights.map { |t| t.created_at.to_i }, weights.map(&:weight)) if weights.any?

      g.minimum_value = g.minimum_value.to_i

      labels = {}
      years = weights.map(&:created_at).map(&:year).uniq
      years.each do |y|
        labels[Time.local(y).to_i] = y.to_s
      end
      g.labels = labels

      send_data(g.to_blob, disposition: 'inline', type: 'image/png',
                           filename: 'weights_chart.png')
    end

    private

    def weight_params
      params.require(:weight).permit(:created_at, :weight)
    end
  end
end
