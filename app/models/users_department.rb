class UsersDepartment < ActiveRecord::Base
  belongs_to :user
  belongs_to :department
  attr_accessible :is_actived, :user_id, :department_id
end
