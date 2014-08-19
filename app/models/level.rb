class Level < ActiveRecord::Base
  belongs_to :competency
  
  has_many :slots, :dependent => :destroy
  attr_accessible :name, :competency_id
end
