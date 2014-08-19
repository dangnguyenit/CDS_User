class CreateOtherSubjectAssesses < ActiveRecord::Migration
  def change
    create_table :other_subject_assesses do |t|
      t.string :score
      t.string :self_score
      t.string :status
      t.boolean :is_notified
      t.string :other_subject_name
      t.integer :approved_user_id
      t.references :user
      t.references :other_subject

      t.timestamps
    end
    add_index :other_subject_assesses, :other_subject_id
    add_index :other_subject_assesses, :user_id
  end
end