class CreateTours < ActiveRecord::Migration
  def self.up
    create_table :tours do |t|
      t.column :started_at, :datetime, null: false
      t.column :total_time, :time, null: false
      t.column :distance, :decimal, precision: 6, scale: 2, null: false
      t.column :average_speed, :decimal, precision: 4, scale: 1, null: false
      t.column :max_speed, :decimal, precision: 4, scale: 1, null: false
      t.column :calories, :decimal, precision: 5, scale: 1, null: false
      t.column :odo, :decimal, precision: 7, scale: 1, null: false
    end
  end

  def self.down
    drop_table :tours
  end
end
