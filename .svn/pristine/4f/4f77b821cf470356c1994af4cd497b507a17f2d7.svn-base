class CurrentTitle < ActiveRecord::Base
  belongs_to :user
  belongs_to :title

  has_many :short_term_objectives
  has_many :comments

  attr_accessible :coach_plan, :rank_id, :long_term, :short_term, :user_id, :title_id
end
