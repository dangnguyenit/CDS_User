class CreateScorings < ActiveRecord::Migration
  def change
    create_table :scorings do |t|
      t.string :score
      t.text :description
      t.references :scoring_scale

      t.timestamps
    end
    add_index :scorings, :scoring_scale_id
  end
end
