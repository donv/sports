# frozen_string_literal: true

require_dependency 'sports/application_controller'

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

      g = WeightChart.chart(weights, size)

      send_data(g.to_blob, disposition: 'inline', type: 'image/png', filename: 'weights_chart.png')
    end

    private

    def weight_params
      params.require(:weight).permit(:created_at, :weight)
    end
  end
end
