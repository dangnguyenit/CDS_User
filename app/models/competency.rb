class Competency < ActiveRecord::Base
  attr_accessible :name, :cds_template_ids

  has_many :levels, :dependent => :destroy

  has_many :titles_competencies
  has_many :titles, through: :titles_competencies
  has_many :cds_templates, through: :titles_competencies

  has_many :cds_templates_competencies
  has_many :cds_templates, through: :cds_templates_competencies
end
