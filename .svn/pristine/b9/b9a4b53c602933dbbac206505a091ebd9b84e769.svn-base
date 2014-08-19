class CreateSlots < ActiveRecord::Migration
  def change
    create_table :slots do |t|
      t.string :name
      t.text :description
      t.text :guideline
      t.references :level

      t.timestamps
    end
    add_index :slots, :level_id
  end
end
