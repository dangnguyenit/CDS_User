class ShortTermObjective < ActiveRecord::Base
  belongs_to :current_title
  has_many :comments
  attr_accessible :action_plan, :title, :short_term, :target_date, :current_title_id
end
