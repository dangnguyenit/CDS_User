class CreateRanks < ActiveRecord::Migration
  def change
    create_table :ranks do |t|
      t.integer :number_competencies_next_level
      t.references :title

      t.timestamps
    end
    add_index :ranks, :title_id
  end
end
