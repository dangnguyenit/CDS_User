class InstancesTerm < ActiveRecord::Base
  belongs_to :term
  belongs_to :instance

  has_many :instance_competencies
  has_many :instance_titles

  has_many :instances_terms_other_subjects
  has_many :other_subjects, through: :instances_terms_other_subjects

  attr_accessible :attitude, :coach_plan, :long_term_string, :short_term, :status, :instance_id, :term_id, :other_subject_ids
end
