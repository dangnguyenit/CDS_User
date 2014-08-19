# This model is used to comunicate with table permission in database
# History: June 06, 2013
# By DatPB

class Permission < ActiveRecord::Base

  #Permission(id: integer, name: string, code: string, created_at: datetime, updated_at: datetime, group_permission_name: string)

  attr_accessible :name, :code, :group_permission_name
  has_many :user_groups_permissions, :dependent => :destroy

  scope :search_name, lambda { |search| where("lower(name) like ?", "%" + search + "%") }
  scope :search_group_permission_name, lambda { |search| where("lower(group_permission_name) like ?", "%" + search + "%") }
  
  def self.get_group_permissions
    Permission.select(:group_permission_name).uniq
  end

  def self.get_permission_in_group_permission(name)
    Permission.select("id, name").where(:group_permission_name => name )
  end

  def self.get_hash_group_permission
    permissions = {}
    group_permissions = Permission.select(:group_permission_name).uniq
    group_permissions.each do |gp|
      permissions[gp.group_permission_name] =  Permission.select("id, name").where(:group_permission_name => gp.group_permission_name)
    end
    return permissions
  end

  def self.get_all_permissions(page, per_page, search, sort = nil,organization_id)
    sort ||= "group_permission_name"
    search = search.downcase
    
    permissions = Permission.select(:group_permission_name).uniq.order(sort).search_group_permission_name(search).paginate(:page => page, :per_page => per_page)

    return_data = {
      "aaData" => [],
      "iTotalDisplayRecords" => permissions.length
    }

    permissions.each do |permission|
      a = {}
      a[:name] = permission.group_permission_name
      group_permissions = Permission.where(group_permission_name: permission.group_permission_name)
      group_permissions.each do |g|
        a[:"#{g.code.split("_")[0]}"] = g.id
      end      
      return_data["aaData"] << a
    end
    p return_data, "=============================================="
    return return_data

  end

end