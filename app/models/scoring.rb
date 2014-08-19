class Scoring < ActiveRecord::Base
  belongs_to :scoring_scale
  
  attr_accessible :description, :score, :scoring_scale_id
end
