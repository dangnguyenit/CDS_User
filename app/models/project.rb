##
# This Model is used to comunicate with table Projects in DB
# @author DatPB
##
class Project < ActiveRecord::Base
  attr_accessible :name, :description, :is_active, :organization_id, :users

  # Relationship with organization
  belongs_to :organization

  has_many :projects_users, :dependent => :destroy
  has_many :users, :through => :projects_users

end
