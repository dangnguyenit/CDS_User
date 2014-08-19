class Title < ActiveRecord::Base
	attr_accessible :name, :short_name, :value, :career_path, :title_group_id

  belongs_to :title_group
  
  has_many :titles_competencies
  has_many :competencies, through: :titles_competencies
  has_many :cds_templates, through: :titles_competencies

  has_many :titles_other_subjects
  has_many :other_subjects, through: :titles_other_subjects
  has_many :cds_templates, through: :titles_other_subjects
end
