class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :evidence
  belongs_to :short_term_objective
  belongs_to :current_title
  attr_accessible :comment, :comment_type, :user_id, :evidence_id, :short_term_objective_id, :current_title_id
end
