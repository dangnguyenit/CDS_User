class SlotAssess < ActiveRecord::Base
  belongs_to :slot
  belongs_to :user
  # Relationship with comment
  has_many :evidences

  attr_accessible :evidence, :status, :is_notified, :value, :self_value, :approved_user_id, :competency_name, :level_name, :slot_name, :slot_id, :user_id
end
