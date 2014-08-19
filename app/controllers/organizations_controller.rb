# This controller is used to process and render home page
# History: June 06, 2013
# By NamTV

class OrganizationsController < ApplicationController
  SORT_MAP = {
    1 => "name"
  }
  ##
  #Get user list except an user with specify ID
  #Parameters::
  # * (Integer) *iDisplayLength*: number of row per page
  # * (Integer) *iDisplayStart*:  starting number
  # * (Integer) *iSortCol_0*: locate of sort column
  # * (String)  *sSearch*: Search string
  #Return::
  # * (json) Matched organization list with paging and number all rows are finded
  #*Author*:: PhuNd
  def index

    if request.xhr?
      per_page = params[:iDisplayLength] || Settings.per_page
      page = params[:iDisplayStart] ? ((params[:iDisplayStart].to_i/per_page.to_i) + 1) : 1
      params[:iSortCol_0] = 1 if params[:iSortCol_0].blank?
      sort_field = SORT_MAP[params[:iSortCol_0].to_i]
      @organizations = Organization.get_all_organizations(page, per_page, params[:sSearch], sort_field + " " + params[:sSortDir_0])
      render :json => @organizations
      return
    end

    @search = params[:search]

  end

  # GET /organizations/:id
  def show
    @organization = current_user.organization
  end

  # GET /organizations/new
  def new
    @organization = Organization.new
    @organization.users.build
  end

  # POST /organizations
  def create
    @organization = Organization.new(params[:organization])
    if @organization.save
      user = @organization.users.first
      user.is_admin = true
      user.save
      redirect_to organizations_path
    else
      render :new
    end

  end

  # GET /organizations/:id/edit
  def edit
    @organization = Organization.find_by_id(params[:id])
    @user_admin = @organization.users.where(:is_admin =>true).first

    @user_admin = @organization.users.new if @user_admin.nil?
  end

  # PUT /organizations/:id
  def update
    @organization = Organization.find_by_id(params[:id])
    organization_name =  params["organization"]["name"]
    if params["organization"]["users_attributes"]["password"].blank?
      params["organization"]["users_attributes"].delete(:password)
      params["organization"]["users_attributes"].delete(:password_confirmation)
    end

    if @organization.update_attributes(params["organization"])
      redirect_to organizations_path
    else
      render :edit
    end

  end

  # DELETE /organizations/:id
  def destroy
    @organization = Organization.find_by_id(params[:id])
    @organization.destroy
    render :json=>{:status =>t('users.destroy.success')}
  end

end


