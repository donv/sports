# frozen_string_literal: true

class CreateRoutes < ActiveRecord::Migration[4.2]
  def self.up
    create_table :routes do |t|
      t.column :name, :string, limit: 64, null: false
    end
    route = Route.create! name: 'Default Route'
    add_column :tours, :route_id, :integer, null: false, default: route.id
    Tour.update_all "route_id = #{route.id}"
    change_column_default :tours, :route_id, nil
  end

  def self.down
    remove_column :tours, :route_id
    drop_table :routes
  end

  class Route < ActiveRecord::Base
    has_many :tours
  end

  class Tour < ActiveRecord::Base
    belongs_to :route
  end
end
