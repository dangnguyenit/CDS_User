# This model is used to comunicate with table Organization in database
# History: June 06, 2013
# By NamTV
class Organization < ActiveRecord::Base
  # Use to log actions
  include PublicActivity::Common
  after_update :after_update_org
  after_create :after_create_org
  before_destroy :before_destroy_org

  #Organization(id: integer, name: string, is_super_org: boolean, description: string)

  attr_accessible :name, :description, :users_attributes
  has_many :users, :dependent => :destroy
  has_many :user_groups, :dependent => :destroy
  has_many :activities, :dependent => :destroy

  accepts_nested_attributes_for :users

  validates :name,:uniqueness => true

  scope :not_super_org, where(:is_super_org => false)
  scope :search_name, lambda { |search| where("lower(name) like ?", "%" + search + "%") }

  def super_org?
    self.is_super_org
  end

  ##
  #Get filtering searching organization list except super org
  #Parameters::
  # * (Integer) *page*: page number that is needed to load
  # * (Integer) *per_page*: number of rows per page
  # * (String) *search*: search string
  # * (Strinf) *sort*: name of sorted column
  #Return::
  # * (json) Matched user list with paging and number all rows are finded
  #*Author*:: PhuND
  def self.get_all_organizations(page, per_page, search, sort = nil)

    search = search.downcase

    organizations = self.not_super_org
    organizations = organizations.search_name(search) if !search.blank?

    return_data = {
      "aaData" => [],
      "iTotalDisplayRecords" => organizations.count
    }
    organizations = organizations.order(sort).paginate(:page => page, :per_page => per_page)
    no = 1
    organizations.each do |organization|
      return_data["aaData"] << [
        no,
        organization.name,
        organization.description,
        "",
        organization.id
      ]
      no += 1
    end
    return return_data
  end

  ##
  #Get organization list except super org
  #Parameters::
  #Return::
  # * (json) Matched org list with name and id
  #*Author*:: PhuND
  def self.get_all_orgs
    organizations = self.not_super_org

    return organizations.map { |o| [o.name, o.id]  }
  end

  ##
  # Write logs after update group
  #*Author*:: DatPB
  def after_update_org

    controller = PublicActivity.get_controller

    # Return if seeding or nothing changes
    return if !controller || self.changed.blank?

    current_user = controller.current_user

    activity = self.create_activity :update, owner: current_user,trackable: self, params: {:detail => I18n.t('logs.update_org', org_name: self.name)}
    activity.organization_id = current_user.organization_id
    activity.save
  end

  ##
  # Write logs after create group
  #*Author*:: DatPB
  def after_create_org
    controller = PublicActivity.get_controller

    # Return if seeding or nothing changes
    return if !controller || self.changed.blank?

    current_user = controller.current_user

    current_user = self.users.first if current_user.nil?

    return unless current_user

    activity = self.create_activity :create, owner: current_user, trackable: self, params: {:detail => I18n.t('logs.create_org', org_name: self.name)}
    activity.organization_id = current_user.organization_id
    activity.save
  end

  ##
  # Write logs before remove group
  #*Author*:: NamTV
  def before_destroy_org
    controller = PublicActivity.get_controller

    # Return if seeding or nothing changes
    return if !controller

    current_user = controller.current_user
    current_user = self.users.first if current_user.nil?

    return unless current_user

    activity = current_user.create_activity :destroy, owner: current_user,trackable: current_user.organization, params: {:detail => I18n.t('logs.destroy_org', org_name: self.name)}
    activity.organization_id = current_user.organization_id
    activity.save
  end

end



