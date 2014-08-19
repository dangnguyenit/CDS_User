class CreateEvidences < ActiveRecord::Migration
  def change
    create_table :evidences do |t|
      t.text :content
      t.string :evidence_type
      t.string :status
      t.string :value
      t.references :slot_assess
      t.references :other_subject_assess

      t.timestamps
    end
    add_index :evidences, :slot_assess_id
    add_index :evidences, :other_subject_assess_id
  end
end
