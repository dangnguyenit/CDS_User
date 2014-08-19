class CreateCdsTemplatesCompetencies < ActiveRecord::Migration
  def change
    create_table :cds_templates_competencies do |t|
      t.belongs_to :cds_template
      t.belongs_to :competency

      t.timestamps
    end
    add_index :cds_templates_competencies, :cds_template_id
    add_index :cds_templates_competencies, :competency_id
  end
end
