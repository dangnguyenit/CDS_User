class TitlesCompetency < ActiveRecord::Base
  attr_accessible :level_ranking, :value, :career_path, :competency_id, :title_id, :cds_template_id

  belongs_to :competency
  belongs_to :title
  belongs_to :cds_template
end
