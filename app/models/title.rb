class Title < ActiveRecord::Base
	attr_accessible :name, :short_name, :value, :career_path, :title_group_id

  belongs_to :title_group
  belongs_to :current_title
  has_many :ranks
  has_many :titles_competencies
  has_many :competencies, through: :titles_competencies
  has_many :cds_templates, through: :titles_competencies


end
