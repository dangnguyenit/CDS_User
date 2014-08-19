# This model is used to comunicate with table User in database
# History: June 06, 2013
# By NamTV

class User < ActiveRecord::Base
  # List attributes need to before log
  LOG_ATTRS = ["first_name", "last_name", "username", "email", "is_deleted", "password", "current_sign_in_at", "user_groups", "user_group_ids", "encrypted_password"]

  # Use to log actions
  include PublicActivity::Common
  after_update :after_update_user
  after_create :after_create_user
  before_destroy :before_destroy_user

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :async, :lockable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :avatar, :failed_attempts, :cached_failed_attempts, :login, :username, :first_name,:last_name, :email, :is_deleted, :password, :password_confirmation, :remember_me, :last_sign_in_at, :last_sign_out_at, :current_sign_in_at, :user_groups, :user_group_ids, :is_admin, :organization, :organization_id, :is_bod, :id_hr, :career_path, :staff_number, :full_name, :abbreviation, :status, :team_leader_id, :is_manager, :is_bod, :is_hr, :department_ids, :is_team_leader, :main_department_id, :pre_department_id, :new_approved
  
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/assets/img/default_avatar.jpg"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
  # validates :username, :uniqueness => true
  validates :staff_number, :uniqueness => true

  validates :full_name, presence: true, length: { minimum: 1, maximum: 256 }

  # attr_accessible :title, :body
  # validates :first_name, :presence => true, :length => {:minimum => 2}
  # validates :last_name, :presence => true, :length => {:minimum => 2}

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(?:\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, :uniqueness => true, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }

  has_many :user_groups_users, :dependent => :destroy
  has_many :user_groups, :through => :user_groups_users

  has_many :projects_users, :dependent => :destroy
  has_many :projects, :through => :projects_users

  has_many :users_departments
  has_many :departments, through: :users_departments

  # Relationship with organization
  belongs_to :organization

  # Relationship with organization
  has_one :current_title

  # Relationship with intance
  has_many :instances

  # Relationship with comment
  has_many :comments
  has_many :instance_comments

  # Relationship with slot assess
  has_many :slot_assesses

  # Relationship with other subject assess
  has_many :other_subject_assesses

  # Relationship with notifications
  has_many :notifications

  #accepts_nested_attributes_for :user_group_user, allow_destroy: true

  scope :not_in_user_group, lambda {|except_ids| where("id NOT IN ( ? ) ", except_ids )}
  scope :id_not, lambda { |except_id| where("users.id != ?", except_id) }
  scope :in_organization, lambda { |id| where(organization_id: id) }
  scope :active, where(:is_deleted => false)
  scope :not_admin, where(:is_admin => false)
  scope :search_full_name, lambda { |search| where("lower(full_name) like ?", "%" + search + "%") }
  scope :complex_sorting, lambda { |sort| joins(:user_groups).order(sort)}
  scope :get_user_with_no_teamlead, lambda { |manager_id| where("team_leader_id = ?", manager_id)}
  scope :get_user_with_no_manager, lambda { |manager_id| where("users.id != ?", manager_id)}
  scope :not_in_department, lambda {|id| where("users.id NOT IN (select ud.user_id from users_departments ud, departments d where d.id = ? and d.id = ud.department_id)", id)}
  
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end
    
  ##
  #Get user list except an user with specify ID
  #Parameters::
  # * (Integer) *id*: id want to be ignored
  # * (Integer) *page*: current page
  # * (Integer) *per_page*: items amount per page
  # * (String) *search*: search string
  # * (String) *sort*: name of sorted column
  #Return::
  # * (Array) Matched user list with paging
  #*Author*:: NamTV
  def self.get_all_users_except_id(id, page, per_page, search, sort = nil,organization_id)
    sort ||= "full_name"
    search = search.downcase
    users = not_admin.in_organization(organization_id).id_not(id).select("id, concat(first_name, ' ', last_name) as full_name, is_deleted")

    users = users.search_full_name(search) if !search.blank?

    return_data = {
      "aaData" => [],
      "iTotalDisplayRecords" => users.count
    }
    users = users.order(sort).paginate(:page => page, :per_page => per_page)
    users.each do |user|
      return_data["aaData"] << [
        user.full_name,
        user.is_deleted,
        "",
        user.id
      ]
    end
    return return_data
  end

  ##
  #Return ::
  # * (String) check if user is active or not
  #*Author*:: NamTV
  def active_for_authentication?
   super && !self.is_deleted
  end

  ##
  #Return::
  # * (Boolean) check if user is admin or not
  #*Author*:: NamTV
  def admin?
    self.is_admin
  end

  ##
  #Return::
  # * (String) full name
  #*Author*:: NamTV
  def user_full_name
    [first_name, last_name].join(" ")
  end

  protected

  ##
  #Return::
  # * (Boolean) email required?
  #*Author*:: NamTV
  def email_required?
    false
  end

  ##
  # Write logs after update user
  #*Author*:: NamTV
  def after_update_user

    not_need_log = (self.changed.select {|attr| LOG_ATTRS.include?(attr)}).blank?
    controller = PublicActivity.get_controller
    # return if nothing changed or
    return if !controller || self.changed.blank? || not_need_log
    current_user = PublicActivity.get_controller.current_user
    return if !current_user

    if self.current_sign_in_at_changed?
      self.create_activity :login, owner: current_user, organization_id: current_user.organization_id , params: {:detail => I18n.t('logs.login')}
    elsif self.id == current_user.id
      self.create_activity :update, owner: current_user, organization_id: current_user.organization_id, params: {:detail => I18n.t('logs.update_profile')}
    else
      self.create_activity :edit_info, owner: current_user,  organization_id: self.organization_id , params: {:detail => I18n.t('logs.edit_user', email: self.email)}
    end
  end

  ##
  # Write logs after create user
  #*Author*:: NamTV
  def after_create_user
    controller = PublicActivity.get_controller
    return if !controller
    current_user = PublicActivity.get_controller.current_user
    if current_user
      self.create_activity :add, owner: current_user,organization_id: self.organization_id, params: {:detail => I18n.t('logs.create_user', email: self.email)}
    else
      self.create_activity :register, owner: self, organization_id: self.organization_id, params: {:detail => I18n.t('logs.register')}
    end
  end

  ##
  # Write logs before remove user
  #*Author*:: NamTV
  def before_destroy_user
    controller = PublicActivity.get_controller
    return if !controller
    current_user = PublicActivity.get_controller.current_user
    update_deleted_name
    self.create_activity :delete, owner: current_user, organization_id: self.organization_id, params: {:detail => I18n.t('logs.delete_user', email: self.email)}
  end

  def update_deleted_name
      logs = Activity.where(:owner_id => self.id)
      logs.update_all(:deleted_name => self.email)
  end

  ##
  # Get Active groups of an user
  # @author DatPB
  ##
  def active_groups
    self.user_groups.active
  end

  ##
  # Get permission of an user (base on project on Group that user join in)
  # @param {Integer} project_id
  # - If user not in group BOD & HR & Org Admin
  #   - If project_id
  #     => It will return {Hash} permissions (for this project): like {project_id: [permissions_code1, permission_code2 ...]}
  #   - else
  #     => It will return {Hash} permissions (for all project): 
  #          like { 
  #                 project_id1: [permissions_code1, permission_code2 ...],
  #                 project_id2: [permissions_code1, permission_code2 ...],
  #                 "total": [per1, per2...]   
  #               }
  # - else
  #   - It will return [Hash] permissions of this user: like {"total": [permissions_code1, permission_code2 ...]}

  # @author DatPB
  ##
  def permissions
    projects_ids = projects.map(&:id)
    permissions = {}

    projects_ids.each do |e|
      permissions[e] = []
    end
    permissions["total"] = []
    
    groups = self.active_groups

    #only set permissions for active groups
    groups.each do |group|
      next if group.project_id && permissions[group.project_id]

      permissions[group.project_id].concat(group.permissions)

      permissions["total"].concat(group.permissions)
    end

    permissions.keys.each do |k|
      permissions[k].uniq!
    end
    
    permissions
  end


  ##
  #Get user list
  #Parameters::
  # * (Integer) *page*: current page
  # * (Integer) *per_page*: items amount per page
  # * (String) *search*: search string
  # * (String) *sort*: name of sorted column
  #Return::
  # * (Array) Matched user list with paging
  #*Author*:: DangNH
  def self.get_all_user(page, per_page, search, sort = nil)
    sort ||= "id"
    search = search.downcase
    if sort.include?"name"
      users = User.complex_sorting(sort).search_full_name(search).paginate(:page => page, :per_page => per_page)
    else  
      users = User.select("id, full_name, email, staff_number, status, career_path, created_at, team_leader_id").order(sort).search_full_name(search).paginate(:page => page, :per_page => per_page)
    end

    return_data = {
      "aaData" => [],
      "iTotalDisplayRecords" => users.count
    }

    users.each do |user|
      a = {}

      a[:career_path] = "Management"
      a[:status] = "Inactive"
      a[:id] = user.id
      a[:full_name] = user.full_name
      a[:email] = user.email
      a[:emp_id] = user.staff_number
      a[:status] = "Active" if user.status
      a[:role] = user.user_groups[0].name
      a[:career_path] = "Technique" if user.career_path.eql?"technique"
      a[:teamlead] = "N/A"
      a[:teamlead] = User.find(user.team_leader_id).full_name if user.team_leader_id

      a[:date_created] = user.created_at.strftime("%d-%m-%Y")

      return_data["aaData"] << a
    end

    return return_data
  end

  ##
  #Get user list
  #Parameters::
  # * (Integer) *page*: current page
  # * (Integer) *per_page*: items amount per page
  # * (String) *search*: search string
  # * (String) *sort*: name of sorted column
  #Return::
  # * (Array) Matched user list with paging
  #*Author*:: DangNH
  def self.get_user_from_deparments(id, page, per_page, search, sort = nil)
    sort ||= "id"
    search = search.downcase
    @department = Department.find(id)
    if sort.include?"name"
      users = @department.users.id_not(@department.manager_id).complex_sorting(sort).search_full_name(search).paginate(:page => page, :per_page => per_page)
    else  
      users = @department.users.id_not(@department.manager_id).order(sort).search_full_name(search).paginate(:page => page, :per_page => per_page)
    end

    return_data = {
      "aaData" => [],
      "iTotalDisplayRecords" => users.count
    }

    users.each do |user|
      a = {}

      a[:teamlead] = "N/A"

      a[:id] = user.id
      a[:full_name] = user.full_name
      a[:email] = user.email
      a[:role] = user.user_groups[0].name
      a[:teamlead] = User.find(user.team_leader_id).full_name if user.team_leader_id

      return_data["aaData"] << a
    end

    return return_data
  end

  ##
  #Get user list
  #Parameters::
  # * (Integer) *page*: current page
  # * (Integer) *per_page*: items amount per page
  # * (String) *search*: search string
  # * (String) *sort*: name of sorted column
  #Return::
  # * (Array) Matched user list with paging
  #*Author*:: DangNH
  def self.get_user_to_teamlead(id, page, per_page, search, sort = nil)
    sort ||= "id"
    search = search.downcase
    thisDepartment = Department.find(id)
    manager_id = thisDepartment.manager_id
    if sort.include?"name"
      users = thisDepartment.users.get_user_with_no_teamlead(manager_id).get_user_with_no_manager(manager_id).complex_sorting(sort).search_full_name(search).paginate(:page => page, :per_page => per_page)
    else  
      users = thisDepartment.users.get_user_with_no_teamlead(manager_id).get_user_with_no_manager(manager_id).order(sort).search_full_name(search).paginate(:page => page, :per_page => per_page)
    end

    return_data = {
      "aaData" => [],
      "iTotalDisplayRecords" => users.count
    }

    users.each do |user|
      a = {}
      a[:id] = user.id
      a[:full_name] = user.full_name
      a[:email] = user.email
      a[:role] = user.user_groups[0].name

      return_data["aaData"] << a
    end

    return return_data
  end

  ##
  #Get user list not in department
  #Parameters::
  # * (Integer) *page*: current page
  # * (Integer) *per_page*: items amount per page
  # * (String) *search*: search string
  # * (String) *sort*: name of sorted column
  #Return::
  # * (Array) Matched user list with paging
  #*Author*:: DangNH
  def self.get_all_user_not_in_department(id, page, per_page, search, sort = nil)
    sort ||= "id"
    search = search.downcase
    if sort.include?"name"
      users = User.not_in_department(id).complex_sorting(sort).search_full_name(search).paginate(:page => page, :per_page => per_page)
     else  
      users = User.not_in_department(id).order(sort).search_full_name(search).paginate(:page => page, :per_page => per_page)
    end

    return_data = {
      "aaData" => [],
      "iTotalDisplayRecords" => users.count
    }

    users.each do |user|
      a = {}
      a[:id] = user.id
      a[:full_name] = user.full_name
      a[:email] = user.email
      a[:role] = user.user_groups[0].name

      return_data["aaData"] << a
    end

    return return_data
  end

  ##
  # Get User for Relationship table
  #  Contain: 1. Manager in active project
  #           2. User not in active project
  #Parameters::
  # * (Integer) *page*: current page
  # * (Integer) *per_page*: items amount per page
  # * (String) *search*: search string
  # * (String) *sort*: name of sorted column
  #Return::
  # * (Array) Matched user list with paging
  #*Author*:: DangNH

  scope :get_users_to_relationship, lambda { where("users.id IN (select departments.manager_id from departments) or users.id IN (select users_departments.user_id from departments, users_departments where departments.status = false and departments.id = users_departments.department_id ) or users.team_leader_id = null or users.id NOT IN (select user_id from users_departments)")}
  scope :manager_in_active_department, lambda { joins(:departments).where("users.id = departments.manager_id")}
  scope :users_in_inactive_department, lambda { joins(:departments).where("departments.status = false")}
  # User.preload(:users_departments).all.select {|u| u.users_departments.empty? }

  def self.get_user_to_relationship(page, per_page, search, sort = nil)
    sort ||= "id"
    search = search.downcase
    
    if Department.all.count > 0
      if sort.include?"name"
        users = User.get_users_to_relationship.complex_sorting(sort).search_full_name(search).paginate(:page => page, :per_page => per_page)
      else  
        users = User.get_users_to_relationship.order(sort).search_full_name(search).paginate(:page => page, :per_page => per_page)
      end
    else
      if sort.include?"name"
        users = User.complex_sorting(sort).search_full_name(search).paginate(:page => page, :per_page => per_page)
      else  
        users = User.order(sort).search_full_name(search).paginate(:page => page, :per_page => per_page)
      end
    end

    return_data = {
      "aaData" => [],
      "iTotalDisplayRecords" => users.count
    }

    users.each do |user|
      a = {}
      a[:id] = user.id
      a[:full_name] = user.full_name
      a[:role] = user.user_groups[0].name
      a[:teamlead] = "N/A"
      a[:teamlead] = User.find(user.team_leader_id).full_name if user.team_leader_id

      return_data["aaData"] << a
    end

    return return_data
  end

  def self.logins_before_captcha
    3
  end

end
