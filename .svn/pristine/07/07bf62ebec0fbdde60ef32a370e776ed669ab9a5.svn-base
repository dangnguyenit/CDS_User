# This model is used to comunicate with table UserGroupsUser in database
# History: June 06, 2013
# By NamTV
class UserGroupsUser < ActiveRecord::Base
  attr_accessible :user_group_id, :user_id, :project_id

  belongs_to :user
  belongs_to :user_group
  belongs_to :project
end

