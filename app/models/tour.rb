# frozen_string_literal: true

class Tour < ActiveRecord::Base
  belongs_to :route

  validates :started_at, :total_time, presence: true
  validates :distance, :average_speed, :max_speed, :calories, :odo,
            numericality: { greater_than_or_equal_to: 0 }
end
