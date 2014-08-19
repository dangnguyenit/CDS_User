class OtherSubject < ActiveRecord::Base
  attr_accessible :name, :instances_term_ids, :scoring_scale_id

  belongs_to :scoring_scale

  has_many :titles_other_subjects
  has_many :cds_templates, through: :titles_other_subjects
  has_many :titles, through: :titles_other_subjects

  has_many :instances_terms_other_subjects
  has_many :instances_terms, through: :instances_terms_other_subjects
end
