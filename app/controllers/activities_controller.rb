# This controller is used to process and render log
# History: June 06, 2013
# By PhuND

class ActivitiesController < ApplicationController
  before_filter :authenticate_user!
  SORT_MAP = {
    1 => "created_at",
    2 => "username"
  }

##
  #Get log list
  #Parameters::
  # * (Integer) *iDisplayLength*: number of row per page
  # * (Integer) *iDisplayStart*:  starting number
  # * (Integer) *iSortCol_0*: locate of sort column
  # * (String)  *sSearch*: Search string
  # * (String)  *from_date*: From date string
  # * (String)  *to_date*: To date string
  #Return::
  # * (json) Matched logs list with paging and number all rows are finded
  #*Author*:: PhuND
  def index
    if request.xhr?
      organization_id = params[:organization_id]
      per_page = params[:iDisplayLength] ||  Settings.per_page
      page = params[:iDisplayStart] ? ((params[:iDisplayStart].to_i/per_page.to_i) + 1) : 1
      params[:iSortCol_0] = 1 if params[:iSortCol_0].blank?
      sort_field = SORT_MAP[params[:iSortCol_0].to_i]
      @activities = Activity.get_all_log(page, per_page, params[:sSearch], params["from_date"], params["to_date"], sort_field + " " + params[:sSortDir_0],organization_id)
      render :json => @activities
      return
    end
  end
end
