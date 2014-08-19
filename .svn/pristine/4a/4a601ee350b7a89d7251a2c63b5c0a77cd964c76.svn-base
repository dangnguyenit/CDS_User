# This model is used to comunicate with table UserGroupsPermission in database
# History: June 06, 2013
# By NamTV

class UserGroupsPermission < ActiveRecord::Base
  attr_accessible :user_group_id, :permission_id
  belongs_to :user_group
  belongs_to :permission
end