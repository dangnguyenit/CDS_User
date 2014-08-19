class CreateCdsTemplates < ActiveRecord::Migration
  def change
    create_table :cds_templates do |t|
      t.string :name
      t.text :status
      t.references :title_group
      t.references :scoring_scale

      t.timestamps
    end
    add_index :cds_templates, :title_group_id
    add_index :cds_templates, :scoring_scale_id
  end
end
