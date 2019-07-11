# frozen_string_literal: true

class Weight < ActiveRecord::Base
  validates :weight, numericality: { greater_than_or_equal_to: 50 }
end
