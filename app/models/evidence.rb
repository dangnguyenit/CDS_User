class Evidence < ActiveRecord::Base
  attr_accessible :content, :status, :value, :evidence_type, :other_subject_assess_id, :slot_assess_id

  belongs_to :slot_assess
  belongs_to :other_subject_assess
  # Relationship with comment
  has_many :comments, :dependent => :destroy
  has_many :photos, :dependent => :destroy
end
