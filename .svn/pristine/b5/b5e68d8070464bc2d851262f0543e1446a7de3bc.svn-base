class CreateTitlesCompetencies < ActiveRecord::Migration
  def change
    create_table :titles_competencies do |t|
      t.string :level_ranking
      t.float :value
      t.string :career_path
      t.belongs_to :title
      t.belongs_to :competency
      t.belongs_to :cds_template

      t.timestamps
    end
    add_index :titles_competencies, :title_id
    add_index :titles_competencies, :competency_id
    add_index :titles_competencies, :cds_template_id
  end
end
