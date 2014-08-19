class Instance < ActiveRecord::Base
	# Relationship with user
  belongs_to :user

  # Relationship with term
  has_many :instances_terms
  has_many :term, through: :instances_terms

  attr_accessible :cds_template_id, :status, :user_id, :term_ids
end
