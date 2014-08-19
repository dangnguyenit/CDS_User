class TitleGroup < ActiveRecord::Base
  attr_accessible :description, :name
  
  belongs_to :cds_template
  has_many :titles

   has_many :title_groups_other_subjects
  has_many :other_subjects, through: :title_groups_other_subjects
  has_many :cds_templates, through: :title_groups_other_subjects
end
