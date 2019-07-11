# frozen_string_literal: true

module Sports
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
