# This model is used to comunicate with table Activity in database
# History: June 06, 2013
# By PhuND
class Activity < PublicActivity::Activity
  # Relationship with organization
  belongs_to :organization
  attr_accessible :organization_id

  scope :in_organization, lambda { |id| where(organization_id: id) }
  scope :search_user_and_action, lambda { |search| where("lower(username) like ? or lower(parameters) like ?", "%" + search + "%", "%" + search + "%") }
  scope :filter_date, lambda { |from_date, to_date| where("activities.created_at >= ? and activities.created_at <= ?", from_date, to_date) }

  ##
  #Get filtering searching logs list
  #Parameters::
  # * (Integer) *page*: page number that is needed to load
  # * (Integer) *per_page*: number of rows per page
  # * (String) *search*: search string
  # * (Strinf) *sort*: name of sorted column
  # * (Integer) *organization_id*: id of organization
  #Return::
  # * (json) Matched logs list with paging and number all rows are finded
  #*Author*:: PhuND
  def self.get_all_log(page, per_page, search, from_date, to_date, sort = nil,organization_id)
    sort ||= "created_at"
    activities = Activity.in_organization(organization_id)
    activities = activities.joins("left join users on users.id = activities.owner_id")
    activities = activities.select("activities.created_at, username, parameters, deleted_name")
    activities = activities.search_user_and_action(search.downcase) if(!search.blank?)
    from_date = DateTime.strptime(from_date, I18n.t('time.short_format'))
    to_date = DateTime.strptime(to_date, I18n.t('time.short_format')).end_of_day
    activities = activities.filter_date(from_date,to_date)

    return_data = {
      "aaData" => [],
      "iTotalDisplayRecords" => activities.count
    }
    activities = activities.order(sort).paginate(:page => page, :per_page => per_page)
    no = 1
    activities.each do |activity|
      return_data["aaData"] << [
        no,
        activity.created_at.localtime.strftime(I18n.t('time.full_format')),
        activity.username || activity.deleted_name,
        activity.parameters[:detail]
      ]
      no += 1
    end
    return return_data
  end
end