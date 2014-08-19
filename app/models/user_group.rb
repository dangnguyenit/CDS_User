# This model is used to comunicate with table UserGroup in database
# History: June 06, 2013
# By DatPB

class UserGroup < ActiveRecord::Base

  # Use to log actions
  include PublicActivity::Common
  after_update :after_update_group
  after_create :after_create_group
  before_destroy :before_destroy_group

  #UserGroup(id: integer, name: string, description: text, is_active: boolean, created_at: datetime, updated_at: datetime, organization_id: integer)

  attr_accessible :name, :description, :is_active, :permissions, :organization, :organization_id, :users, :permission_ids
  has_many :user_groups_users, :dependent => :destroy
  has_many :users, :through => :user_groups_users
  has_many :user_groups_permissions, :dependent => :destroy
  has_many :permissions, :through => :user_groups_permissions

  # Relationship with organization
  belongs_to :organization

  validates :name, :uniqueness => {:scope => :organization_id}

  scope :in_organization, lambda { |id| where(organization_id: id) }
  scope :search_name, lambda { |search| where("lower(name) like ?", "%" + search + "%") }
  scope :name_not, lambda { |except_name| where("name != ?", except_name) }

  scope :active, where(:is_active => true)

  ##
  #Get filtering searching user_group list except Administrator
  #Parameters::
  # * (Integer) *page*: page number that is needed to load
  # * (Integer) *per_page*: number of rows per page
  # * (String) *search*: search string
  # * (String) *sort*: name of sorted column
  #Return::
  # * (Hash) Matched user list with paging and number all rows are finded
  #*Author*:: NamTV
  def self.get_all_user_groups(page, per_page, search, sort = nil,organization_id)
    sort ||= "name"
    search = search.downcase
    
    user_groups = UserGroup.name_not("Administrator").order(sort).search_name(search).paginate(:page => page, :per_page => per_page)

    return_data = {
      "aaData" => [],
      "iTotalDisplayRecords" => user_groups.count
    }

    user_groups.each do |group|
      a = {}
      a[:id] = group.id
      a[:name] = group.name
      a[:permission_ids] = group.permission_ids
      a[:date_created] = group.created_at.strftime('%d/%m/%Y')
      a[:status] = "Inactive"
      a[:status] = "Active" if group.is_active  

      return_data["aaData"] << a
    end

    return return_data
  end

  def self.get_all_users_in_group(page, per_page, search, sort = nil,organization_id, group_id)
    sort ||= "full_name"
    search = search.downcase
    user_group = self.name_not("Administrator").in_organization(organization_id).find(group_id)
    users = user_group.users
    users = users.where(:is_admin => false).select("users.id, concat(first_name, ' ', last_name) as full_name, username, is_deleted")

    users = users.where("lower(concat(first_name, ' ', last_name)) like ?", "%" + search + "%") if !search.blank?

    return_data = {
      "aaData" => [],
      "iTotalDisplayRecords" => users.count
    }
    users = users.order(sort).paginate(:page => page, :per_page => per_page)
    no = per_page.to_i * (page.to_i-1) + 1
    users.each do |user|
      return_data["aaData"] << [
        no,
        user.full_name,
        user.username,
        user.is_deleted,
        "",
        user.id
      ]
      no += 1
    end
    return return_data
  end

  def self.get_all_users_not_in_group(page, per_page, search, sort = nil,organization_id, group_id)
    sort ||= "full_name"
    search = search.downcase
    user_group = self.name_not("Administrator").in_organization(organization_id).find(group_id)
    userids = user_group.user_ids
    except_users = userids.blank? ? User : User.not_in_user_group(userids)
    except_users = except_users.where(:is_admin => false).select("users.id, concat(first_name, ' ', last_name) as full_name, username, is_deleted")

    except_users = except_users.where("lower(concat(first_name, ' ', last_name)) like ?", "%" + search + "%") if !search.blank?

    return_data = {
      "aaData" => [],
      "iTotalDisplayRecords" => except_users.count
    }
    except_users = except_users.order(sort).paginate(:page => page, :per_page => per_page)
    no = per_page.to_i * (page.to_i-1) + 1
    except_users.each do |user|
      return_data["aaData"] << [
        no,
        user.full_name,
        user.username,
        user.is_deleted,
        "",
        user.id
      ]
      no += 1
    end
    return return_data
  end

  def self.get_all_users_in_org(page, per_page, search, sort = nil,organization_id)
    sort ||= "full_name"
    search = search.downcase
    users = User.where(:is_admin => false, :organization_id => organization_id).select("users.id, concat(first_name, ' ', last_name) as full_name, username, is_deleted")

    users = users.where("lower(concat(first_name, ' ', last_name)) like ?", "%" + search + "%") if !search.blank?

    return_data = {
      "aaData" => [],
      "iTotalDisplayRecords" => users.count
    }
    users = users.order(sort).paginate(:page => page, :per_page => per_page)
    no = per_page.to_i * (page.to_i-1) + 1
    users.each do |user|
      return_data["aaData"] << [
        no,
        user.full_name,
        user.username,
        user.is_deleted,
        "",
        user.id
      ]
      no += 1
    end
    return return_data
  end

  def get_hash_selected_permissions
    selected_permissions = {}
    self.permissions.each  do |p|
      if !selected_permissions[p.group_permission_name]
        selected_permissions[p.group_permission_name] = Permission.select("id, name").where(:id => p.id)
      else
        selected_permissions[p.group_permission_name] += Permission.select("id, name").where(:id => p.id)
      end
    end
    return selected_permissions
  end

  ##
  #Get group list in a organization
  #Parameters::
  # *(Integer) *organization_id*: id of organization
  #Return::
  # * Matched group list
  #*Author*:: PhuND
  def self.get_all_user_groups_in_org(organization_id)
    user_groups = self.in_organization(organization_id)
  end

  protected
  ##
  # Write logs after update group
  #*Author*:: NamTV
  def after_update_group

    controller = PublicActivity.get_controller

    # Return if seeding or nothing changes
    return if !controller || self.changed.blank?

    current_user = PublicActivity.get_controller.current_user

    self.create_activity :update, owner: current_user,organization_id: self.organization_id, params: {:detail => I18n.t('logs.update_group', group_name: self.name)}

  end

  ##
  # Write logs after create group
  #*Author*:: NamTV
  def after_create_group
    controller = PublicActivity.get_controller

    # Return if seeding or nothing changes
    return if !controller || self.changed.blank?

    current_user = PublicActivity.get_controller.current_user

    self.create_activity :create, owner: current_user,organization_id: self.organization_id, params: {:detail => I18n.t('logs.create_group', group_name: self.name)}
  end

  ##
  # Write logs before remove group
  #*Author*:: NamTV
  def before_destroy_group
    controller = PublicActivity.get_controller

    # Return if seeding or nothing changes
    return if !controller

    current_user = PublicActivity.get_controller.current_user

    self.create_activity :destroy, owner: current_user,organization_id: self.organization_id, params: {:detail => I18n.t('logs.destroy_group', group_name: self.name)}
  end
end