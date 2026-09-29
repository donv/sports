# frozen_string_literal: true

class Route < ActiveRecord::Base
  has_many :tours, dependent: :restrict_with_error

  validates :name, presence: true
end
