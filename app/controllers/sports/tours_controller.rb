# frozen_string_literal: true

require 'gruff'

module Sports
  class ToursController < ApplicationController
    def graph_small
      graph 160
    end

    def graph(size = 640)
      g = ToursChart.chart(size)

      send_data(g.to_blob, disposition: 'inline', type: 'image/png', filename: 'tours_chart.png')
    end
  end
end
