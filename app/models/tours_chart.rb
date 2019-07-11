# frozen_string_literal: true

module ToursChart
  def self.chart(size)
    g = Gruff::Line.new(size)
    g.theme_37signals
    g.title = I18n.t(:chart)
    g.font = '/usr/share/fonts/bitstream-vera/Vera.ttf'
    g.legend_font_size = 14
    g.hide_dots = true

    tours = Tour.order(:started_at).to_a

    g.data(I18n.t(:time), tours.map { |t| t.total_time.min + t.total_time.sec / 60 })
    g.data(I18n.t(:distance), tours.map(&:distance))

    g.minimum_value = 0

    g.labels = labels(tours)

    g.maximum_value = g.maximum_value.to_i
    g
  end

  def self.labels(tours)
    labels = {}
    tours.each_with_index do |t, i|
      labels[i] = t.started_at.strftime('%y-%m-%d')
    end
    labels
  end
end
