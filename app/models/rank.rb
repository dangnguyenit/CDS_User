class Rank < ActiveRecord::Base
  belongs_to :title
  attr_accessible :number_competencies_next_level, :title_id
end
