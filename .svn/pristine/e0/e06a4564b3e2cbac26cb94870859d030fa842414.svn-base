class CreateLevels < ActiveRecord::Migration
  def change
    create_table :levels do |t|
      t.string :name
      t.references :competency

      t.timestamps
    end
    add_index :levels, :competency_id
  end
end
