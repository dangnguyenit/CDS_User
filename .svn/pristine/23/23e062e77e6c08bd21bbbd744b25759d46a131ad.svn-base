class SlotAssess < ActiveRecord::Base
  belongs_to :slot
  belongs_to :user
  # Relationship with comment
  has_many :evidences

  attr_accessible :evidence, :status, :value, :competency_name, :level_name, :slot_name, :slot_id, :user_id
end
