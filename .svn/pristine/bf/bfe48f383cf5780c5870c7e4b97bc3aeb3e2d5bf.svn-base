# This controller is used to manager user_group
# History: June 06, 2013
# By NamTV

class UserGroupsController < ApplicationController
  before_filter :authenticate_user!
  SORT_GROUP_MAP = {
    0 => "id",
    1 => "name",
    2 => "description",
    3 => "is_active",
    4 => "created_at"

  }
  SORT_USER_MAP = {
    1 => "full_name",
    2 => "username"
  }

  SORT_PERMISSON_MAP = {
    0 => "group_permission_name",
    1 => "group_permission_name"
  }

  ##
  #Get user_group list except an user_group of Administrator
  #Parameters::
  # * (Integer) *iDisplayLength*: number of row per page
  # * (Integer) *iDisplayStart*:  starting number
  # * (Integer) *iSortCol_0*: locate of sort column
  # * (String)  *sSearch*: Search string
  #Return::
  # * (json) Matched user list with paging and number all rows are finded
  #*Author*:: PhuND
  def index
    if request.xhr?
      organization_id = params["organization_id"]
      per_page = params[:iDisplayLength] || Settings.per_page
      page = params[:iDisplayStart] ? ((params[:iDisplayStart].to_i/per_page.to_i) + 1) : 1
      params[:iSortCol_0] = 1 if params[:iSortCol_0].blank?
      sort_field = SORT_GROUP_MAP[params[:iSortCol_0].to_i]
      @user_groups = UserGroup.get_all_user_groups(page, per_page, params[:sSearch], sort_field + " " + params[:sSortDir_0],organization_id)
      render :json => @user_groups
      return
    end
  end

  ##
  #New an user group
  #Parameters::
  #Return::
  # * (Array) Permission load form initialize
  # *  Model: new instance of User Group
  #*Author*:: PhuND
  def new
    @user_group = UserGroup.new
    @permissions = {}
    @group_permissions = Permission.get_group_permissions
    @group_permissions.each do |g|
      @permissions[g.group_permission_name] = Permission.get_permission_in_group_permission(g.group_permission_name)
    end
  end

  ##
  #Creat user group
  #Parameters::
  # * (object) *user_group*: current user_group object
  # * (Array) *permissions*: permission list that user group have
  #Return::
  # * (object) an new instance user_group
  #*Author*:: DangNH
  def create
    @user_group = UserGroup.new(name: params["name"])
    permission_ids = params["selected_permisions"]
    org_id = params[:organization_id]
    @user_group.permission_ids = permission_ids
    @user_group.organization_id = org_id

    respond_to do |format|
      if @user_group.save
        format.json { render json: @user_group }
      else
        format.json { render json: @user_group.errors.messages, status: :unprocessable_entity }
      end
    end

    # respond_to do |format|
    #   if @user_group.save
    #     format.json { render json: @user_group }
    #   else
    #     format.json { render json: @user_group.errors.messages, status: :unprocessable_entity}
    #     @permissions = Permission.get_hash_group_permission
    #   end
    # end
    # if @user_group.save
    #   redirect_to organization_user_groups_path
    # else
    #   flash[:error] = t('user_group.exist')
    #   @permissions = Permission.get_hash_group_permission
    #   render :new
    # end

  end

  ##
  #Get user group with specify ID
  #Parameters::
  # * (Integer) *id*: current user group id
  #Return::
  # * (User Group) Matched user with id
  #*Author*:: PhuND
  def edit
    @user_group = UserGroup.find_by_id(params[:id])
    # @permissions = Permission.get_hash_group_permission
    @selected_permisions = @user_group.get_hash_selected_permissions

    if request.xhr?
      organization_id = params["organization_id"]
      per_page = params[:iDisplayLength] ||  Settings.per_page
      page = params[:iDisplayStart] ? ((params[:iDisplayStart].to_i/per_page.to_i) + 1) : 1
      params[:iSortCol_0] = 1 if params[:iSortCol_0].blank?
      sort_field = SORT_USER_MAP[params[:iSortCol_0].to_i]

      @users = UserGroup.get_all_users_in_group(page, per_page, params[:sSearch], sort_field + " " + params[:sSortDir_0],organization_id,params[:id])
      render :json => @users, :view =>:edit
      return
    end
    render :edit
  end

  def get_available_user
    if request.xhr?
      organization_id = params["organization_id"]
      per_page = params[:iDisplayLength] ||  Settings.per_page
      page = params[:iDisplayStart] ? ((params[:iDisplayStart].to_i/per_page.to_i) + 1) : 1
      params[:iSortCol_0] = 1 if params[:iSortCol_0].blank?
      sort_field = SORT_USER_MAP[params[:iSortCol_0].to_i]

      @all_users = UserGroup.get_all_users_not_in_group(page, per_page, params[:sSearch], sort_field + " " + params[:sSortDir_0],organization_id, params[:user_group_id])

      render :json => @all_users, :view =>:edit
      return
    end
  end

  def add_user_to_group
    @user_group = UserGroup.find_by_id(params[:user_group_id])
    if params[:ids]
      users = User.find(params[:ids])
      case params[:process]
        when "addItem", "addAllItems"
          @user_group.users << users
          @user_group.save
        when "removeItem", "removeAllItems"
          @user_group.users.delete(users)
          @user_group.save
      end
    end
    render :json => @user_group.users,:view =>:edit
  end

  def update_permissions
    @user_group = UserGroup.find_by_id(params[:user_group_id])
    if(params[:process] == "all")
      @selected_permisions = @user_group.get_hash_selected_permissions
      render :json => {permissions: @selected_permisions, message: "Success"},:view =>:edit_temp
      return
    end
    if params[:ids]
      permissions = Permission.find(params[:ids])
      case params[:process]
        when "add"
          @user_group.permissions << permissions
          @user_group.save
        when "remove"
          @user_group.permissions.delete(permissions)
          @user_group.save
      end
    end
     @selected_permisions = @user_group.get_hash_selected_permissions
    render :json => @selected_permisions,:view =>:edit
  end

  #
  #Handle detroy an user_group
  #Parameters::
  # * (integer) *id*: current user_group id to destroy
  #Return::
  # * (json) status: ok=>done
  #*Author*:: PhuND
  #
  def destroy
    @user_group = UserGroup.find_by_id(params[:data])
    

    respond_to do  |format|
      if @user_group.destroy
        format.json { render json: @user_group }
      else
        format.json { render json: @user_group.errors.messages}
      end
    end

    # render :json=>{:status =>t('users.destroy.success')}
  end

  #Update user group with specify ID
  #Parameters::
  # * (Integer) *id*: current user group id
  # * (Array) *permissions*: permissions that user group have
  #Return::
  # * (User) Matched user group with id
  #*Author*:: DangNH
  def update
    @user_group = UserGroup.find(params[:data])

    respond_to do |format|
      if @user_group.update_attributes(name: params[:name]) && UserGroupsPermission.where(user_group_id: 5).destroy_all && @user_group.permission_ids = params[:selected_permisions]
        format.json { render json: @user_group }
      else
        format.json { render json: @user_group.errors.messages, status: :unprocessable_entity }
      end
    end


    # @user_group = UserGroup.find_by_id(params[:id])
    # permission_ids = params["permissions"] || []
    # permission_ids.map! {|p| p.to_i}
    # current_permission_ids = @user_group.permission_ids
    # group_name =  params["user_group"]["name"]

    # existed_group = UserGroup.where(:name =>group_name)
    # if existed_group.empty? || existed_group.first.id == params[:id].to_i
    #   if @user_group.update_attributes(params["user_group"])

    #     # The update action make log saved or not
    #     is_logged = !@user_group.previous_changes.blank?
    #     if current_permission_ids != permission_ids
    #       @user_group.permission_ids = permission_ids

    #       # Create log if not logged before
    #       @user_group.create_activity :update, owner: current_user, params: {:detail => I18n.t('logs.update_group', group_name: @user_group.name)} if !is_logged
    #     end
    #     redirect_to organization_user_groups_path(params[:organization_id])
    #   end
    # else
    #   flash[:error] = t('user_group.exist')
    #   redirect_to edit_organization_user_group_path(params[:organization_id],@user_group)
    # end
  end

  def get_all_permission
    if request.xhr?
      organization_id = params["organization_id"]
      per_page = params[:iDisplayLength] || Settings.per_page
      page = params[:iDisplayStart] ? ((params[:iDisplayStart].to_i/per_page.to_i) + 1) : 1
      params[:iSortCol_0] = 1 if params[:iSortCol_0].blank?
      sort_field = SORT_PERMISSON_MAP[params[:iSortCol_0].to_i]
      @permissions = Permission.get_all_permissions(page, per_page, params[:sSearch], sort_field + " " + params[:sSortDir_0],organization_id)
      render :json => @permissions
      return
    end
  end

  def change_status
    @user_group = UserGroup.find(params[:data])

    respond_to do |format|
      if @user_group.update_attributes(is_active: params[:status])
        format.json { render json: @user_group }
      else
        format.json { render json: @user_group.errors.messages, status: :unprocessable_entity }
      end
    end
  end

end