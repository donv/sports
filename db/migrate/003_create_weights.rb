class CreateWeights < ActiveRecord::Migration
  def self.up
    create_table :weights do |t|
      t.column :created_at, :timestamp, :null => false
      t.column :weight, :decimal, :precision => 4, :scale => 1, :null => false
    end
  end

  def self.down
    drop_table :weights
  end
end