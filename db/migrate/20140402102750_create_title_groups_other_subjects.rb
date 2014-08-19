class CreateTitleGroupsOtherSubjects < ActiveRecord::Migration
  def change
    create_table :title_groups_other_subjects do |t|
      t.string :scoring
      t.integer :title_id
      t.belongs_to :title_group
      t.belongs_to :other_subject
      t.belongs_to :cds_template

      t.timestamps
    end
    add_index :title_groups_other_subjects, :title_group_id
    add_index :title_groups_other_subjects, :other_subject_id
    add_index :title_groups_other_subjects, :cds_template_id
  end
end
