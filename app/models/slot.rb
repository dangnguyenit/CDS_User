class Slot < ActiveRecord::Base
  belongs_to :level

  # Relationship with slot_assess
  has_many :slot_assesses
  
  attr_accessible :description, :name, :level_id, :guideline
end
