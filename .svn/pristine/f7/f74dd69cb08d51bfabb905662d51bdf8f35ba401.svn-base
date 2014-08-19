class OtherSubjectAssess < ActiveRecord::Base
  belongs_to :other_subject
  belongs_to :user

  has_many :evidences

  attr_accessible :self_score, :score, :status, :is_notified,:other_subject_name, :approved_user_id, :other_subject_id, :user_id
end
