# frozen_string_literal: true

require 'test_helper'

module Sports
  class Test < ActiveSupport::TestCase
    test 'truth' do
      assert_kind_of Module, Sports
    end
  end
end
