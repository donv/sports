# frozen_string_literal: true

module Sports
  class ToursController < ApplicationController
    def index
      @tours = Tour.includes(:route).order(started_at: :desc)
      @tour = Tour.new(started_at: Time.zone.now)
    end

    def show
      @tour = Tour.find(params.expect(:id))
    end

    def new
      @tour = Tour.new(started_at: Time.zone.now)
    end

    def edit
      @tour = Tour.find(params.expect(:id))
    end

    def create
      @tour = Tour.new(tour_params)
      if @tour.save
        flash[:notice] = t(:tour_created)
        redirect_to action: :index
      else
        render action: :new
      end
    end

    def update
      @tour = Tour.find(params.expect(:id))
      if @tour.update(tour_params)
        flash[:notice] = t(:tour_updated)
        redirect_to action: :show, id: @tour
      else
        render action: :edit
      end
    end

    def destroy
      Tour.find(params.expect(:id)).destroy
      redirect_to action: :index
    end

    def graph_small
      graph 160
    end

    def graph(size = 640)
      g = ToursChart.chart(size)

      send_data(g.to_image.to_blob, disposition: 'inline', type: 'image/png', filename: 'tours_chart.png')
    end

    private

    def tour_params
      params.expect(tour: %i[started_at total_time distance average_speed max_speed calories odo route_id])
    end
  end
end
