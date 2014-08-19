class CreateOtherSubjects < ActiveRecord::Migration
  def change
    create_table :other_subjects do |t|
      t.string :name
      t.references :scoring_scale

      t.timestamps
    end
    add_index :other_subjects, :scoring_scale_id
  end
end
