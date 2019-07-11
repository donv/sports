# frozen_string_literal: true

module WeightChart
  def self.chart(weights, size)
    g = Gruff::Line.new(size)
    g.title = I18n.t(:weight).capitalize
    g.hide_legend = true
    g.hide_dots = true if weights.size > 25
    g.baseline_value = 100

    g.dataxy(I18n.t(:weight), weights.map { |t| t.created_at.to_i }, weights.map(&:weight)) if weights.any?

    g.minimum_value = g.minimum_value.to_i

    g.labels = labels(weights)
    g
  end

  def self.labels(weights)
    labels = {}
    years = weights.map(&:created_at).map(&:year).uniq
    years.each do |y|
      labels[Time.local(y).to_i] = y.to_s
    end
    labels
  end
end
