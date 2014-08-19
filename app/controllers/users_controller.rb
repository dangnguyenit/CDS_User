# This controller is used to manager user
# History: June 06, 2013
# By NamTV

require_dependency 'importing/importer'

class UsersController < ApplicationController
  before_filter :authenticate_user!
  SORT_MAP = {
    0 => "id",
    1 => "full_name",
    2 => "abbreviation",
    3 => "email",
    4 => "staff_number",
    5 => "name",
    6 => "created_at",
    7 => "status"

  }

  SORT_MAP_RELATIONSHIP = {
    0 => "id",
    1 => "full_name",
    2 => "name",
    3 => "team_leader_id"
  }

  ##
  #Get user list except an user with specify ID
  #Parameters::
  # * (Integer) *iDisplayLength*: number of row per page
  # * (Integer) *iDisplayStart*:  starting number
  # * (Integer) *iSortCol_0*: locate of sort column
  # * (String)  *sSearch*: Search string
  #Return::
  # * (json) Matched user list with paging and number all rows are finded
  #*Author*:: NamTV
  def index
    if request.xhr?
      organization_id = params["organization_id"]
      per_page = params[:iDisplayLength] ||  Settings.per_page
      page = params[:iDisplayStart] ? ((params[:iDisplayStart].to_i/per_page.to_i) + 1) : 1
      params[:iSortCol_0] = 1 if params[:iSortCol_0].blank?
      sort_field = SORT_MAP[params[:iSortCol_0].to_i]
      # @users = User.get_all_users_except_id(current_user.id, page, per_page, params[:sSearch], sort_field + " " + params[:sSortDir_0],organization_id)
      @users = User.get_all_user(page, per_page, params[:sSearch], sort_field + " " + params[:sSortDir_0])
      render :json => @users
      return
    end
  end

  ##
  #Handle new an user
  #Parameters::
  #Return::
  # * (object) an new instance user
  #*Author*:: NamTV
  #
  def new
     @user = User.new
     @user_groups = UserGroup.get_all_user_groups_in_org(params[:organization_id])
  end

  ##
  #Handle create an user
  #Parameters::
  # * (object) *user*: current input user
  # * (Array) *user_groups*: current groups that user join
  #Return::
  # * (object) an new instance user
  #*Author*::NamTV
  #
  def create
    group_ids = params["group_id"]
    org_id = params[:organization_id]
    @user =  User.new(full_name: params[:full_name], password: params[:password], password_confirmation: params[:password], email: params[:email], status: params[:status], staff_number: params[:employee_id], career_path: params[:career_path], team_leader_id: nil)
    @user.user_group_ids = group_ids
    @user.organization_id = org_id

    respond_to do |format|
      if @user.save
        format.json { render json: @user }
      else
        format.json { render json: @user.errors.messages, status: :unprocessable_entity }
      end
    end
  end

  ##
  #Handle edit an user
  #Parameters::
  # * (integer) *id*: current user id to edit
  #Return::
  # * (object) an new instance user
  #*Author*:: NamTV
  #
  def edit
    @user = User.find_by_id(params[:id])
    @user_groups = UserGroup.get_all_user_groups_in_org(params[:organization_id])
    render :edit
  end

  ##
  #Handle update an user
  #Parameters::
  # * (integer) *id*: current user id to update
  # * (object) *user*: current user input
  # * (Array) *user_groups*: current groups that user join
  #Return::
  # * (object) an new instance user
  #*Author*:: NamTV
  #
  def update
    group_ids = params[:group_id]
    org_id = params[:organization_id]
    @user = User.find_by_id(params[:user_id])
    current_group_ids = @user.user_group_ids

    respond_to do |format|
      if @user.update_attributes(full_name: params[:full_name], abbreviation: params[:abbreviation], email: params[:email], status: params[:status], staff_number: params[:employee_id], career_path: params[:career_path])

        is_logged = !@user.previous_changes.blank?
        if current_group_ids != group_ids
          @user.user_group_ids = group_ids
          format.json { render json: @user }
        end
      else
        format.json { render json: @user.errors.messages, status: :unprocessable_entity }
      end
    end
  end


  ##
  #Handle detroy an user
  #Parameters::
  # * (integer) *id*: current user id to destroy
  #Return::
  # * (json) status: ok=>done
  #*Author*:: NamTV
  #
  def destroy
    @user = User.find_by_id(params[:data])
    respond_to do |format|
      if @user.destroy
        format.json { render json: @user }
      end
    end
  end

  ##
  # Render page for importing list of user
  # @author DatPB
  #
  def new_list_users

  end

  ##
  # Handle import list of user
  # @author DatPB
  ##
  def import_users
    @file = params[:upload]
    return render_error :upload unless @file && @file.try(:content_type)

    if @file.content_type =~ /^text\/csv|^application\/vnd.ms-excel/
      importer = Importing::Importer.new(@file.read)

      if importer.failed?
        # if failed
        Rails.logger.warn "*** Import failed: #{importer.error.message}\nBacktrace: #{importer.error.backtrace[0,5].join("\n")}"
        render_error :import
      else
        # "full_name", "abbreviation", "email", "status", "staff_number", "group"
        @records = importer.results
        # puts @records.inspect

        @records.reject! { |c| c.blank? }

        count = 0

        require_headers = ["full_name", "abbreviation", "email", "status", "staff_number",  "group"]

        headers = importer.headers

        if @records.length > 0
          headers = @records.first.keys
        end

        if headers.nil?
          render_error :header
          return
        end

        # headers.each do |e|
        #   unless require_headers.index(e)
        #     render_error :header
        #     return
        #   end
        # end

        result = true
        headers.each do |h|
          result = require_headers.include?(h.to_s)
          unless result
            render_error :header
            return
          end
        end

        @records.each do |user|
          next if user.blank?

          puts user.inspect

          created_user = User.new({
            full_name: user[:full_name],
            abbreviation: user[:abbreviation],
            email: user[:email],
            username: user[:abbreviation],
            password: "1qazxsw2",
            password_confirmation: "1qazxsw2",
            status: user[:status],
            staff_number: user[:staff_number],
            organization_id: current_user.organization_id
          })
          group_name = user[:group].downcase
          group_id = UserGroup.find_by_sql("Select * from user_groups where lower(name) ='#{group_name}'")[0].id
          

          created_user.user_group_ids = group_id

          # created_user.skip_confirmation!
          count += 1 if created_user.save
          puts created_user.errors.inspect
        end
        
        flash[:notice] = "There are #{count} users have been created."
        redirect_to organization_users_path(current_user.organization_id)
      end
    else
      render_error :content_type, :type => @file.content_type
    end
  end

  ##
  # Handle import list of user
  # @author DangNH
  ##
  def upload_avatar
    @user = User.find(params[:id])
    @file = params[:avatar]

    # return render_error :avatar unless @file && @file.try(:content_type)
    if @file.content_type =~ /^image\/jpeg|png|jpg/
      if @user.update_attributes(avatar: params[:avatar])
        redirect_to user_pa_organization_user_path
      end
    else  
      flash[:alert] = "Your file's type is invalid. Please try another one!"
      redirect_to user_pa_organization_user_path
      # render_error :content_type, :type => @file.content_type
    end

  end

  ##
  # Handle upload photo for evidence
  # @author DangNH
  ##
  def upload_photo
    @user = User.find(params[:id])
    @files = params[:file]
    evidence = params[:evidence_id]
    
    @files.each_with_index do |file, i|
      if params[:file]["#{i}"].content_type =~ /^image\/jpeg|png|jpg/
        @photo = Photo.create(image: params[:file]["#{i}"], evidence_id: evidence)
      else  
        flash[:alert] = "Your file's type is not an image. Please try another one!"
        render :nothing => true
      end
    end
    render :nothing => true
  end

  ##
  # Reset pass to default for user
  #Parameters::
  # * (integer) *data*: current user id to reset
  #Return::
  # * (json) data: true
  #*Author*:: DangNH
  #
  def reset_password
    id = params[:data]
    @user = User.find(id)
    respond_to do |format|
      if @user.update_attributes(password: "1qazxsw2", password_confirmation: "1qazxsw2")
        format.json { render json: @user }
      end
    end
  end
  
  ##
  # Resend confirmation email to user
  # @author DangNH
  ##
  def resend_email
    id = params[:data]
    @user = User.find(id)
    respond_to do |format|
      if @user.send_confirmation_instructions
        format.text { render text: "Email has been sent out!" }
      end
    end
  end

  ##
  # Do actions belong message input
  # 1. assign team leader for use
  # 2. remove team leader of user and set default team leader is department's manager 
  # @author DangNH
  ##
  def actions
    teamleader_id = params[:teamleader_id]
    user_id = params[:user_id]
    message = params[:message]
    department_id = params[:department_id]

    @user = User.find(user_id)
    
    if message.eql?"assign"
      respond_to do |format|
        if @user.update_attributes(team_leader_id: teamleader_id)
          format.json { render json: @user }
        else
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    elsif message.eql?"remove"
      respond_to do |format|
        if @user.update_attributes(team_leader_id: Department.find(department_id).manager_id)
          format.json { render json: @user }
        else
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  ##
  # Resend confirmation email to user
  # @author DangNH
  ##
  def user_relationship
    if request.xhr?
      organization_id = params["organization_id"]
      per_page = params[:iDisplayLength] ||  Settings.per_page
      page = params[:iDisplayStart] ? ((params[:iDisplayStart].to_i/per_page.to_i) + 1) : 1
      params[:iSortCol_0] = 1 if params[:iSortCol_0].blank?
      sort_field = SORT_MAP_RELATIONSHIP[params[:iSortCol_0].to_i]
      # @users = User.get_all_users_except_id(current_user.id, page, per_page, params[:sSearch], sort_field + " " + params[:sSortDir_0],organization_id)
      @users = User.get_user_to_relationship(page, per_page, params[:sSearch], sort_field + " " + params[:sSortDir_0])
      render :json => @users
      return
    end
  end

  ##
  #Do actions belong to messages
  #Parameters::
  # * (integer) *data*: current user id to do actions
  #Return::
  # * (json) status: ok=>done
  #*Author*:: DangNH
  #
  def actions_relationship
    manager_id = params[:data]
    user_id = params[:user_id]
    message = params[:message]

    if message.eql?"edit"
      @user = User.find(user_id)
      respond_to do |format|
        if @user.update_attributes(team_leader_id: manager_id)
          format.json { render json: @user }
        else
          format.json { render json: @user.errors, status: :unprocessable_entity}
        end
      end
    elsif message.eql?"remove"
      @user = User.find(user_id)
      respond_to do |format|
        if @user.update_attributes(team_leader_id: nil)
          format.json { render json: @user }
        else
          format.json { render json: @user.errors, status: :unprocessable_entity}
        end
      end
    end
  end

  ##
  #Handle change status of user
  #Parameters::
  # * (integer) *data*: current user id
  #Return::
  # * (json) status: ok=>done
  #*Author*:: DangNH
  #
  def change_status
    @user = User.find(params[:data])

    respond_to do |format|
      if @user.update_attributes(status: params[:status])
        format.json { render json: @user }
      else
        format.json { render json: @user.errors.messages, status: :unprocessable_entity }
      end
    end
  end

  ##
  #Show notification comment page for user
  #Parameters::
  # * (integer) *id*: current user id to find user
  #Return::
  # * (json) status: ok=>done
  #*Author*:: DangNH
  #
  def notification_approve
    @notifications = current_user.notifications.where(notification_type: ["approve", "submit"]).order("created_at desc")
    render :layout => false
  end

  ##
  #Show notification comment page for user
  #Parameters::
  # * (integer) *id*: current user id to find user
  #Return::
  # * (json) status: ok=>done
  #*Author*:: DangNH
  #
  def notification_reject
    @notifications = current_user.notifications.where(notification_type: ["reject", "return"]).order("created_at desc")
    render :layout => false
  end

  ##
  #Show notification comment page for user
  #Parameters::
  # * (integer) *id*: current user id to find user
  #Return::
  # * (json) status: ok=>done
  #*Author*:: DangNH
  #
  def notification_cmt
    @notifications = current_user.notifications.where(notification_type: "comment").order("created_at desc")



    # evidence_id_slot_owner = @notifications.where(obj_type: "evidence_id_slot_owner").group_by(&:obj_id)
    # evidence_id_slot = @notifications.where(obj_type: "evidence_id_slot").group_by(&:obj_id)
    # evidence_id_other_subject_owner = @notifications.where(obj_type: "evidence_id_other_subject_owner").group_by(&:obj_id)
    # evidence_id_other_subject = @notifications.where(obj_type: "evidence_id_other_subject").group_by(&:obj_id)
    # short_term_objective_id_owner = @notifications.where(obj_type: "short_term_objective_id_owner").group_by(&:obj_id)
    # short_term_objective_id = @notifications.where(obj_type: "short_term_objective_id").group_by(&:obj_id)
    # current_title_id_short_term_owner = @notifications.where(obj_type: "current_title_id_short_term_owner").group_by(&:obj_id)
    # current_title_id_short_term = @notifications.where(obj_type: "current_title_id_short_term").group_by(&:obj_id)
    # current_title_id_long_term_owner = @notifications.where(obj_type: "current_title_id_long_term_owner").group_by(&:obj_id)
    # current_title_id_long_term = @notifications.where(obj_type: "current_title_id_long_term").group_by(&:obj_id)


    render :layout => false
  end

  ##
  #Show timeline page for user
  #Parameters::
  # * (integer) *id*: current user id to find user
  #Return::
  # * (json) status: ok=>done
  #*Author*:: DangNH
  #
  def timeline
    @user = User.find(params[:data])
    @slot_assesses = @user.slot_assesses.where("status != 'Not Added Yet'")
    # @slot_assesses = @user.slot_assesses.where(status: "Not Assessed Yet")
    # @slot_assessed = @user.slot_assesses.where("status = 'Passed' or status = 'Not Passed'")
    slot_assess_ids = @slot_assesses.map(&:id)
    # @slot_assesses.each{ |sa| slot_assess_ids.push(sa.id)}
    # @slot_assessed.each{ |sa| slot_assess_ids.push(sa.id)}

    type = params[:type] || ""
    case type
      when ""
        @evidences = Evidence.where(slot_assess_id: slot_assess_ids).limit(3).order("created_at desc")
      when "last_month"
        @evidences = Evidence.where(slot_assess_id: slot_assess_ids).where("created_at > ?", (Time.now - 1.month)).order("created_at desc")
      when "last_6_months"
        @evidences = Evidence.where(slot_assess_id: slot_assess_ids).where("created_at > ?", (Time.now - 6.month)).order("created_at desc")
      when "last_year"
        @evidences = Evidence.where(slot_assess_id: slot_assess_ids).where("created_at > ?", (Time.now - 1.year)).order("created_at desc")      
      when "show_all"
        @evidences = Evidence.where(slot_assess_id: slot_assess_ids).order("created_at desc")        
    end

    # @recently_added_slots = @user.slot_assesses.where(SlotAssess.arel_table[:status].not_eq("Not Added Yet")).limit(8).order("updated_at desc")
    # @not_added_slots = @user.slot_assesses.where(status: "Not Added Yet").limit(8).order("updated_at desc")

    render :layout => false
  end

  ##
  #Show home page for user
  #Parameters::
  # * (integer) *id*: current user id to find user
  #Return::
  # * (json) status: ok=>done
  #*Author*:: DangNH
  #
  def home
    @user = User.find(params[:data])
    slot_assess_ids = []
    if @user.is_manager
      array_department_id = Department.where(manager_id: @user.id).map(&:id)
      array_users = User.joins(:users_departments).where(["department_id IN (?)", array_department_id]).uniq.map(&:id)
      @slot_assesses = SlotAssess.joins(:user).where("users.id In (?)", array_users)
      slot_assess_ids = @slot_assesses.map(&:id)
    elsif @user.is_team_leader
      array_users = User.where(team_leader_id: @user.id).map(&:id)
      array_users = array_users.push(@user.id)
      @slot_assesses = SlotAssess.joins(:user).where("users.id In (?)", array_users)
      slot_assess_ids = @slot_assesses.map(&:id)
    elsif @user.is_bod || @user.is_hr
      array_users = User.all.map(&:id)
      @slot_assesses = SlotAssess.joins(:user).where("users.id In (?)", array_users)
      slot_assess_ids = @slot_assesses.map(&:id)
    end

    type = params[:type] || ""
    case type
      when ""
        @evidences = Evidence.where(slot_assess_id: slot_assess_ids).limit(3).order("created_at desc")
      when "last_month"
        @evidences = Evidence.where(slot_assess_id: slot_assess_ids).where("created_at > ?", (Time.now - 1.month)).order("created_at desc")
      when "last_6_months"
        @evidences = Evidence.where(slot_assess_id: slot_assess_ids).where("created_at > ?", (Time.now - 6.month)).order("created_at desc")
      when "last_year"
        @evidences = Evidence.where(slot_assess_id: slot_assess_ids).where("created_at > ?", (Time.now - 1.year)).order("created_at desc")      
      when "show_all"
        @evidences = Evidence.where(slot_assess_id: slot_assess_ids).order("created_at desc")        
    end

    render :layout => false
  end

  ##
  #Show team member page for user
  #Parameters::
  # * (integer) *id*: current user id to find user
  #Return::
  # * (json) status: ok=>done
  #*Author*:: DangNH
  #
  def team_member
    @user = User.find(params[:data])
    department_id = params[:department_id] || "all_team_member"
    search = params[:search_key] || ""
    per_page = params[:per_page] || 10

    if @user.is_manager
      if department_id == "all_team_member"
        array_department_id = @user.departments.map(&:id)
        @team_members = User.joins(:users_departments).where(["department_id IN (?)", array_department_id]).where("users.id != ?", @user.id).where("lower(full_name) like ?", "%" + search + "%").uniq
        @max_length = @team_members.length
        @team_members = @team_members.limit(per_page.to_i)
      else
        @team_members = Department.where(manager_id: @user.id, id: department_id).first.users.where("users.id != ?", @user.id).where("lower(full_name) like ?", "%" + search + "%")
        @max_length = @team_members.length
        @team_members = @team_members.limit(per_page)
      end
    end

    if @user.is_hr || @user.is_bod
      if department_id == "all_team_member"
        array_department_id = Department.all.map(&:id)
        @team_members = User.joins(:users_departments).where(["department_id IN (?)", array_department_id]).where("users.id != ?", @user.id).where("lower(full_name) like ?", "%" + search + "%").uniq
        @max_length = @team_members.length
        @team_members = @team_members.limit(per_page.to_i)
      else
        @team_members = Department.where(id: department_id).first.users.where("users.id != ?", @user.id).where("lower(full_name) like ?", "%" + search + "%")
        @max_length = @team_members.length
        @team_members = @team_members.limit(per_page)
      end
    end

    if @user.is_team_leader
      if department_id == "all_team_member"
        array_department_id = @user.departments.map(&:id)
        array_manager_id = @user.departments.map(&:manager_id)
        array_manager_id.push(@user.id)
        @team_members = User.joins(:users_departments).where(["department_id IN (?)", array_department_id]).where(["users.id NOT IN (?)", array_manager_id]).where("users.team_leader_id = (?)", @user.id).where("lower(full_name) like ?", "%" + search + "%").uniq
        @max_length = @team_members.length
        @team_members = @team_members.limit(per_page.to_i)
      else
        @only_department = @user.departments.where(id: department_id).first 
        @team_members = @only_department.users.where(["users.id NOT IN (?)", [@user.id, @only_department.manager_id]]).where("users.team_leader_id = (?)", @user.id).where("lower(full_name) like ?", "%" + search + "%")
        @max_length = @team_members.length
        @team_members = @team_members.limit(per_page)
      end
    end

    render :layout => false
  end

  ##
  #Show recenly not added page for user
  #Parameters::
  # * (integer) *id*: current user id to find user
  #Return::
  # * (json) status: ok=>done
  #*Author*:: DangNH
  #
  def recently_not_added_slot
    @user = User.find(params[:data])
    type = params[:type] || ""
    if type == 'timeline' || type == ""
      @recently_added_slots = @user.slot_assesses.where(SlotAssess.arel_table[:status].not_eq("Not Added Yet")).limit(8).order("updated_at desc")
      @not_added_slots = @user.slot_assesses.where(status: "Not Added Yet").limit(8).order("updated_at")
    elsif type == 'home'
      if @user.is_manager
        array_department_id = Department.where(manager_id: @user.id).map(&:id)
        array_users = User.joins(:users_departments).where(["department_id IN (?)", array_department_id]).uniq.map(&:id)
        @recently_added_slots = SlotAssess.joins(:user).where("users.id IN (?) and slot_assesses.status != (?)", array_users, "Not Added Yet").limit(8).order("updated_at desc")
        @not_added_slots = SlotAssess.joins(:user).where("users.id IN (?) and slot_assesses.status = (?)", array_users, "Not Added Yet").limit(8).order("updated_at")

      elsif @user.is_team_leader
        array_users = User.where(team_leader_id: @user.id).map(&:id)
        array_users = array_users.push(@user.id)
        @recently_added_slots = SlotAssess.joins(:user).where("users.id IN (?) and slot_assesses.status != (?)", array_users, "Not Added Yet").limit(8).order("updated_at desc")
        @not_added_slots = SlotAssess.joins(:user).where("users.id IN (?) and slot_assesses.status = (?)", array_users, "Not Added Yet").limit(8).order("updated_at")
      elsif @user.is_bod || @user.is_hr
        array_users = User.all.map(&:id)
        @recently_added_slots = SlotAssess.joins(:user).where("users.id IN (?) and slot_assesses.status != (?)", array_users, "Not Added Yet").limit(8).order("updated_at desc")
        @not_added_slots = SlotAssess.joins(:user).where("users.id IN (?) and slot_assesses.status = (?)", array_users, "Not Added Yet").limit(8).order("updated_at")
      end
        


      # @recently_added_slots = @user.slot_assesses.where(SlotAssess.arel_table[:status].not_eq("Not Added Yet")).limit(8).order("updated_at desc")
      
      # @not_added_slots = @user.slot_assesses.where(status: "Not Added Yet").limit(8).order("updated_at")
    end
      
    render :layout => false
  end

  ##
  #Show PA page for user
  #Parameters::
  # * (integer) *id*: current user id to find user
  #Return::
  # * (json) status: ok=>done
  #*Author*:: DangNH
  #
  def user_pa
    @user = User.find(params[:id])

    @approve_notifications = current_user.notifications.where(notification_type: ["approve", "submit"], is_seen: false).count
    @reject_notifications = current_user.notifications.where(notification_type: ["reject", "return"], is_seen: false).count
    @comment_notifications = current_user.notifications.where(notification_type: "comment", is_seen: false).count

    if check_higher_position(@user, current_user)
      if @user.is_manager
        @departments = Department.where(manager_id: @user.id)
      end

      if @user.is_hr || @user.is_bod
        @departments = Department.all
      end

      if @user.is_team_leader
        @departments = @user.departments
      end

      create_slot_assess_for_user(@user.id)
      

      @competencies = Competency.order("id")
      @levels = Level.order("id")
      @slots = Slot.order("id")

      @slot_assesses = @user.slot_assesses.order("id")

      @other_subjects = OtherSubject.order("id")
      @other_subject_assesses = @user.other_subject_assesses.order("id")

      if @user.new_approved
        calculate_title(@user.id)
        @user.update_attributes(new_approved: false)
      end

      if @user.current_title.rank_id
        @current_title = Rank.find(@user.current_title.rank_id).title.name
      else
        @current_title = "N/A"
      end

    else
      sign_out @user
      flash[:alert] = "Permission is denied"
      redirect_to new_user_session_path
    end
  end

  ##
  # Show Recently Added page
  #Parameters::
  # * (integer) *data*: current slot assess id
  #Return::
  # * (json) status: ok=>done
  #*Author*:: DangNH
  #
  def recently_added
    @user = User.find(params[:data])
    @slot_assesses = @user.slot_assesses.where(SlotAssess.arel_table[:status].not_eq("Not Added Yet")).order("updated_at desc")

    @scoring_scale = @user.departments.first.cds_template.scoring_scale

    
    render :layout => false
  
  end

  ##
  # Show About page
  #Parameters::
  # * (integer) *data*: current slot assess id
  #Return::
  # * (json) status: ok=>done
  #*Author*:: DangNH
  #
  def about
    @user = User.find(params[:data])
    @current_title = @user.current_title
    # c = Comment.arel_table
    # @comments = @current_title.comments.where(c[:comment_type].eq("long_term").or(c[:comment_type].eq("short_term")))
    view_more = params[:view_more] || ""

    if view_more.eql?("long")  || params[:type].eql?("create_long_term")
      @long_comments = @current_title.comments.where(comment_type: "long_term").order("id")
    else
      @long_comments = @current_title.comments.where(comment_type: "long_term").limit(5).order("id")
    end

    if view_more.eql?("short") || params[:type].eql?("create_short_term")
      @short_comments = @current_title.comments.where(comment_type: "short_term").order("id")
    else
      @short_comments = @current_title.comments.where(comment_type: "short_term").limit(5).order("id")
    end

    @number_of_long = @current_title.comments.where(comment_type: "long_term").count
    @number_of_short = @current_title.comments.where(comment_type: "short_term").count
    
    render :layout => false
  end

  ##
  # Show Current Status page
  #Parameters::
  # * (integer) *data*: current slot assess id
  #Return::
  # * (json) status: ok=>done
  #*Author*:: DangNH
  #
  def current_status
    @user = User.find(params[:data])
    @competencies = Competency.order("id")
    @other_subject_assesses = @user.other_subject_assesses.order("id")

    @c_hash = calculate_ranking_of_competency(@user.id)[0]

    if @user.current_title.rank_id
      @current_title = Rank.find(@user.current_title.rank_id).title.name
    else
      @current_title = "N/A"
    end


    if @user.departments.length > 0 || current_user.is_bod || current_user.is_hr
      @scoring_scale = @user.departments.first.cds_template.scoring_scale
    else
      sign_out @user 
      flash[:alert] = "Your Account currently is not in any Department. Please contact your Admin to resolve."
      redirect_to new_user_session_path      
    end
    
    @slot_assesses = @user.slot_assesses.order("id")
    @passed_slots = @user.slot_assesses.where(status: "Passed")

    @hash = {}
    @competencies.each do |c|
      @hash["#{c.name}"] = {}
      count = 0
      @passed_slots.each do |ps|
        if ps.competency_name.eql?(c.name)
          count += 1
        end
      end
      @hash["#{c.name}"]["count"] = count
      count_slot = 0
      c.levels.each do |l|
        count_slot += l.slots.count
      end
      @hash["#{c.name}"]["count_slots"] = count_slot
    end
    
    render :layout => false
  end

  ##
  # Show All Slot page
  #Parameters::
  # * (integer) *data*: current slot assess id
  #Return::
  # * (json) status: ok=>done
  #*Author*:: DangNH
  #
  def all_slot
    type = params[:type] || 'all_slots'
    @user = User.find(params[:data])

    @scoring_scale = @user.departments.first.cds_template.scoring_scale
    
    @competencies = Competency.all

    case type
      when 'all_slots'
        @slot_assesses = @user.slot_assesses.order("id")
      when 'passed_slots'
        @slot_assesses = @user.slot_assesses.where(status: "Passed").order("id")
      when 'not_passed_slots'
        @slot_assesses = @user.slot_assesses.where(status: "Not Passed").order("id")
      when 'not_assessed_yet_slots'
        @slot_assesses = @user.slot_assesses.where(status: "Not Assessed Yet").order("id")
      when 'not_added_slots'
        @slot_assesses = @user.slot_assesses.where(status: "Not Added Yet").order("id")
    end
    render :layout => false
  end

  ##
  # Show Short Term Objective page
  #Parameters::
  # * (integer) *data*: current slot assess id
  #Return::
  # * (json) status: ok=>done
  #*Author*:: DangNH
  #
  def short_term_objective
    @user = User.find(params[:data])
    per_page = params[:obj_per_page] || 5
    short_term_id = params[:obj_id] || ""

    @current_title = @user.current_title
    if short_term_id == ""
      @max_length = @current_title.short_term_objectives.count
      @short_term_objectives = @current_title.short_term_objectives.limit(per_page).order("created_at desc")
    else
      @max_length = 1
      @short_term_objectives = @current_title.short_term_objectives.where(id: short_term_id).order("created_at desc")
    end
    render :layout => false
  end

  ##
  # Show Comments page
  #Parameters::
  # * (integer) *data*: current slot assess id
  #Return::
  # * (json) status: ok=>done
  #*Author*:: DangNH
  #
  def comments
    @user = User.find(params[:user_id])

    if params[:type].eql?("short_term_objective")
      @short_term_objective = ShortTermObjective.find(params[:data])
      @number_of_comments = @short_term_objective.comments.count
      if params[:more_type] == "true"
        @comments = @short_term_objective.comments.order("id")
      else
        @comments = @short_term_objective.comments.limit(5).order("id")
      end
    elsif params[:type].eql?("evidence")
      @evidence = Evidence.find(params[:data])
      @number_of_comments = @evidence.comments.count
      if params[:more_type] == "true"
        @comments = @evidence.comments.order("id")
      else
        @comments = @evidence.comments.limit(5).order("id") 
      end      
    end
    render :layout => false
  end

  ##
  # Show All Other Subject page
  #Parameters::
  # * (integer) *data*: current slot assess id
  #Return::
  # * (json) status: ok=>done
  #*Author*:: DangNH
  #
  def all_other_subject
    @user = User.find(params[:data])


    @all_other_subjects = @user.other_subject_assesses.order("id")
    @title_groups_other_subjects = TitleGroupsOtherSubject.order("id")

    render :layout => false
  end

  ##
  # Show Slot Detail
  #Parameters::
  # * (integer) *data*: current slot assess id
  #Return::
  # * (json) status: ok=>done
  #*Author*:: DangNH
  #
  def slot_detail
    @user = User.find(params[:user_id])
    @slot_assess = SlotAssess.find(params[:data])
    @approved_user = User.find(@slot_assess.approved_user_id).full_name if @slot_assess.approved_user_id
    @description = @slot_assess.slot.description.gsub(". ", ".\n")
    @guideline = @slot_assess.slot.guideline.gsub(". ", ".\n")

    type = params[:type] || ""
    case type
      when ""
        @evidences = @slot_assess.evidences.limit(3).order("created_at desc")
      when "last_month"
        @evidences = @slot_assess.evidences.where("created_at > ?", (Time.now - 1.month)).order("created_at desc")
      when "last_6_months"
        @evidences = @slot_assess.evidences.where("created_at > ?", (Time.now - 6.month)).order("created_at desc")
      when "last_year"
        @evidences = @slot_assess.evidences.where("created_at > ?", (Time.now - 1.year)).order("created_at desc")      
      when "show_all"
        @evidences =@slot_assess.evidences.order("created_at desc")
      when "show_only"
        @evidences = @slot_assess.evidences.where(id: params[:obj_id]) 
    end
    # @recently_added_slots = @user.slot_assesses.where(SlotAssess.arel_table[:status].not_eq("Not Added Yet")).order("updated_at desc")

    render :layout => false
  end

  ##
  # Show Slot Detail
  #Parameters::
  # * (integer) *data*: current slot assess id
  #Return::
  # * (json) status: ok=>done
  #*Author*:: DangNH
  #
  def other_subject_detail
    @user = User.find(params[:user_id])
    @other_subject_assess = OtherSubjectAssess.find(params[:data])
    @approved_user = User.find(@other_subject_assess.approved_user_id).full_name if @other_subject_assess.approved_user_id
    # @description = @other_subject_assess.slot.description.gsub(". ", ".\n")
    # @guideline = @other_subject_assess.slot.guideline.gsub(". ", ".\n")

    type = params[:type] || ""
    case type
      when ""
        @evidences = @other_subject_assess.evidences.limit(3).order("created_at desc")
      when "last_month"
        @evidences = @other_subject_assess.evidences.where("created_at > ?", (Time.now - 1.month)).order("created_at desc")
      when "last_6_months"
        @evidences = @other_subject_assess.evidences.where("created_at > ?", (Time.now - 6.month)).order("created_at desc")
      when "last_year"
        @evidences = @other_subject_assess.evidences.where("created_at > ?", (Time.now - 1.year)).order("created_at desc")      
      when "show_all"
        @evidences =@other_subject_assess.evidences.order("created_at desc")        
    end
    # @recently_added_slots = @user.other_subject_assesses.where(OtherSubjectAssess.arel_table[:status].not_eq("Not Added Yet")).order("updated_at desc")

    render :layout => false
  end

  ##
  # Show Recently Added Slider
  #Parameters::
  # * (integer) *data*: current slot assess id
  #Return::
  # * (json) status: ok=>done
  #*Author*:: DangNH
  #
  def recently_added_slider
    @user = User.find(params[:user_id])
    search = params[:key_word] || ""
    @recently_added_slots = @user.slot_assesses.where(SlotAssess.arel_table[:status].not_eq("Not Added Yet")).where("lower(slot_name) like ? or lower(competency_name) like ?", "%" + search + "%", "%" + search + "%").order("updated_at desc")
    render :layout => false
  end

  ##
  # Remove evidence for Recently Added
  #Parameters::
  # None
  #Return::
  # * (json) status: ok=>done
  #*Author*:: DangNH
  #
  def remove_evidence
    @slot_assess = SlotAssess.find(params[:data])

    respond_to do |format|
      if @slot_assess.update_attributes(status: "Not Added Yet", value: nil, self_value: nil, is_notified: false)
        @slot_assess.evidences.destroy_all
        Notification.where(obj_type: ["slot", "evidence_id_slot", "evidence_id_slot_owner"], obj_id: @slot_assess.id).destroy_all
        format.json { render json: @slot_assess }
      else
        format.json { render json: @slot_assess.errors.messages, status: :unprocessable_entity }
      end
    end

  end

  ##
  # Do actions belong to params[:type]
  #Parameters::
  # * (json) *params*: Params for action
  #Return::
  # * (json) status: ok=>done
  #*Author*:: DangNH
  #
  def action_instances_tem
    type =  params[:type]
    case type
      when "edit_name"
        respond_to do |format|
          @user = User.find(params[:data])
          if @user.update_attributes(full_name: params[:value])
            format.json { render json: @user }
          else
            format.json { render json: @user.errors.messages, status: :unprocessable_entity }
          end
        end

      when "change_password"
        respond_to do |format|
          @user = User.find(params[:data])
          if @user.valid_password?(params[:old_pass])
            if @user.update_attributes(password: params[:new_pass], password_confirmation: params[:new_pass])
              format.json { render json: @user }
            else
              format.json { render json: @user.errors.messages, status: :unprocessable_entity }
            end
          else
            format.json { render text: "Current Password is incorrect" }
          end
        end

      when "long_create"
        respond_to do |format|
          @current_title = CurrentTitle.find(params[:data])
          if @current_title.update_attributes(long_term: params[:value])
            format.json { render json: @current_title }
          else
            format.json { render json: @current_title.errors.messages, status: :unprocessable_entity }
          end
        end

      when "long_edit"
        respond_to do |format|
          @current_title = CurrentTitle.find(params[:data])
          if @current_title.update_attributes(long_term: params[:value])
            format.json { render json: @current_title }
          else
            format.json { render json: @current_title.errors.messages, status: :unprocessable_entity }
          end
        end

      when "short_create"
        respond_to do |format|
          @current_title = CurrentTitle.find(params[:data])
          if @current_title.update_attributes(short_term: params[:value])
            format.json { render json: @current_title }
          else
            format.json { render json: @current_title.errors.messages, status: :unprocessable_entity }
          end
        end
        
      when "short_edit"
        respond_to do |format|
          @current_title = CurrentTitle.find(params[:data])
          if @current_title.update_attributes(short_term: params[:value])
            format.json { render json: @current_title }
          else
            format.json { render json: @current_title.errors.messages, status: :unprocessable_entity }
          end
        end

      when "delete_long"
        respond_to do |format|
          @current_title = CurrentTitle.find(params[:data])
          @comments = Comment.where(current_title_id: params[:data], comment_type: "long_term")
          if @current_title.update_attributes(long_term: nil) && @comments.destroy_all
            format.json { render json: @current_title }
          else
            format.json { render json: @current_title.errors.messages, status: :unprocessable_entity }
          end
        end

      when "delete_short"
        respond_to do |format|
          @current_title = CurrentTitle.find(params[:data])
          @comments = Comment.where(current_title_id: params[:data], comment_type: "short_term")
          if @current_title.update_attributes(short_term: nil) && @comments.destroy_all
            format.json { render json: @current_title }
          else
            format.json { render json: @current_title.errors.messages, status: :unprocessable_entity }
          end
        end

      when "create_comment"
        p params[:comment], "================================="
        comment_type = params[:comment_type] || nil
        sub_type = params[:sub_type] || nil
        obj_id = params[:obj_id] || nil

        respond_to do |format|
          @comment = Comment.new(comment: params[:comment], comment_type: sub_type, :"#{comment_type}" => obj_id, user_id: params[:data] )
            
          if @comment.save
            unless sub_type.eql?("")
              owner_notification = Notification.create(user_id: params[:user_owner_id], obj_user_id: params[:data], notification_type: "comment", obj_id: obj_id, obj_type: "#{comment_type}_#{sub_type}_owner", is_seen: false) unless params[:user_owner_id].eql?(params[:data])
              if comment_type == "evidence_id"
                user_array = Evidence.find(obj_id).comments.map(&:user_id).uniq
                if user_array.length > 0
                  user_array.delete(params[:user_owner_id].to_i)
                  user_array.delete(params[:data].to_i)
                  user_array.each do |user_id|
                    notification = Notification.create(user_id: user_id, obj_user_id: params[:data], notification_type: "comment", obj_id: obj_id, obj_type: "#{comment_type}_#{sub_type}", is_seen: false)
                  end
                end

              elsif comment_type == "current_title_id"
                user_array = CurrentTitle.find(obj_id).comments.map(&:user_id).uniq
                if user_array.length > 0
                  user_array.delete(params[:user_owner_id].to_i)
                  user_array.delete(params[:data].to_i)
                  user_array.each do |user_id|
                  notification = Notification.create(user_id: user_id, obj_user_id: params[:data], notification_type: "comment", obj_id: obj_id, obj_type: "#{comment_type}_#{sub_type}", is_seen: false)
                end
              end  
                
              end 
            else

              owner_notification = Notification.create(user_id: params[:user_owner_id], obj_user_id: params[:data], notification_type: "comment", obj_id: obj_id, obj_type: "#{comment_type}_owner", is_seen: false) unless params[:user_owner_id].eql?(params[:data])
              user_array = ShortTermObjective.find(obj_id).comments.map(&:user_id).uniq
              if user_array.length > 0
                user_array.delete(params[:user_owner_id].to_i)
                user_array.delete(params[:data].to_i)
                user_array.each do |user_id|
                  notification = Notification.create(user_id: user_id, obj_user_id: params[:data], notification_type: "comment", obj_id: obj_id, obj_type: comment_type, is_seen: false)
               end
              end  
            end
            
            format.json { render json: @comment }
          else
            format.json { render json: @comment.errors.messages, status: :unprocessable_entity }
          end
        end

      when "edit_comment"
        respond_to do |format|
          @comment = Comment.find(params[:data])
          if @comment.update_attributes(comment: params[:value])
            format.json { render json: @comment }
          else
            format.json { render json: @comment.errors.messages, status: :unprocessable_entity }
          end
        end

      when "delete_comment"
        respond_to do |format|
          @comment = Comment.find(params[:data])
          if @comment.destroy
            format.json { render json: @comment }
          else
            format.json { render json: @comment.errors.messages, status: :unprocessable_entity }
          end
        end

      when "update_status"
        respond_to do |format|
          @slot_assess = SlotAssess.find(params[:data])
          if @slot_assess.update_attributes(status: params[:status])
            format.json { render json: @slot_assess }
          else
            format.json { render json: @slot_assess.errors.messages, status: :unprocessable_entity }
          end
        end

      when "create_short_term_objective"
        @current_title = CurrentTitle.find(params[:data])

        @short_term_objective = ShortTermObjective.new(short_term: params[:short_term_objective], action_plan: params[:action_plan], target_date: params[:target_date], current_title_id: @current_title.id)
        respond_to do |format|
          if @short_term_objective.save
            format.json { render json: @short_term_objective }
          else
            format.json { render json: @short_term_objective.errors.messages, status: :unprocessable_entity }
          end
        end

      when "edit_short_term_objective"
        @short_term_objective = ShortTermObjective.find(params[:data])

        respond_to do |format|
          if @short_term_objective.update_attributes(short_term: params[:short_term_objective], action_plan: params[:action_plan], target_date: params[:target_date])
            format.json { render json: @short_term_objective }
          else
            format.json { render json: @short_term_objective.errors.messages, status: :unprocessable_entity }
          end
        end

      when "delete_short_term_objective"
        respond_to do |format|
          @short_term_objective = ShortTermObjective.find(params[:data])
          @comments = Comment.where(short_term_objective_id: params[:data])
          if @short_term_objective.destroy && @comments.destroy_all
            format.json { render json: @short_term_objective }
          else
            format.json { render json: @short_term_objective.errors.messages, status: :unprocessable_entity }
          end
        end
      
      when "create_evidence"
        slot_assess_ids = params[:values]
        evidence = params[:text]

        respond_to do |format|
          slot_assess_ids.each do |s|
            @evidence = Evidence.new(content: evidence, status: "New", slot_assess_id: s)
            unless @evidence.save
              format.json { render json: @evidence.errors.messages, status: :unprocessable_entity }              
            end
          end
          format.json { render json: slot_assess_ids }
        end
       
      when "edit_evidence"
        @evidence = Evidence.find(params[:data])
        respond_to do |format|
          if @evidence.update_attributes(content: params[:value])
            format.json { render json: @evidence }
          else
            format.json { render json: @evidence.errors.messages, status: :unprocessable_entity }
          end
        end

      when "delete_evidence"
        respond_to do |format|
          @evidence = Evidence.find(params[:data])
          @comments = Comment.where(evidence_id: params[:data])
          if @evidence.destroy && @comments.destroy_all
            format.json { render json: @evidence }
          else
            format.json { render json: @evidence.errors.messages, status: :unprocessable_entity }
          end
        end

      when "create_obj_evidence"
        evidence = params[:text]
        obj_assess_id = params[:value]
        obj_type = params[:obj_type]

        respond_to do |format|

          @evidence = Evidence.new(content: evidence, status: "New", :"#{obj_type}" => obj_assess_id)
          if @evidence.save
            format.json { render json: @evidence }
          else
            format.json { render json: @evidence.errors.messages, status: :unprocessable_entity }              
          end
        end

      when "add_self_value"
        respond_to do |format|
          @slot_assess = SlotAssess.find(params[:data])
          if @slot_assess.update_attributes(self_value: params[:self_value])
            format.json { render json: @slot_assess }
          else
            format.json { render json: @slot_assess.errors.messages, status: :unprocessable_entity }
          end
        end

      when "add_self_score"
        respond_to do |format|
          @other_subject_assess = OtherSubjectAssess.find(params[:data])
          if @other_subject_assess.update_attributes(self_score: params[:self_score])
            format.json { render json: @other_subject_assess }
          else
            format.json { render json: @other_subject_assess.errors.messages, status: :unprocessable_entity }
          end
        end

      when "approve_slot_detail"
        respond_to do |format|
          @slot_assess = SlotAssess.find(params[:data])
          approved_user = User.find(params[:approved_user_id])
          is_bod = params[:role]

          unless is_bod.eql?("") #is bod
            p "Bod"
            if @slot_assess.update_attributes(value: params[:value], status: "Passed", approved_user_id: approved_user.id, is_notified: false)
              User.find(@slot_assess.user.id).update_attributes(new_approved: true)
              @notification2 = Notification.create(user_id: @slot_assess.user.id, obj_user_id: approved_user.id, notification_type: "approve", obj_id: @slot_assess.id, obj_type: "slot", is_seen: false)
              format.json { render json: @slot_assess }
            else
              format.json { render json: @slot_assess.errors.messages, status: :unprocessable_entity }
            end
          else
            p "Manager"
            if @slot_assess.update_attributes(value: params[:value], approved_user_id: approved_user.id, is_notified: true)
              
              # for teamleader notification
              if approved_user.is_team_leader
                # Notify to user
                notification1 = Notification.create(user_id: @slot_assess.user.id, obj_user_id: approved_user.id, notification_type: "approve", obj_id: @slot_assess.id, obj_type: "slot", is_seen: false)

                # Notify to manager -> submit
                manager = User.find(Department.find( @slot_assess.user.main_department_id).manager_id)
                notification2 = Notification.create(user_id: manager.id, obj_user_id: @slot_assess.user.id, notification_type: "submit", obj_id: @slot_assess.id, obj_type: "slot", is_seen: false)
              end

              # for manager notification
              if approved_user.is_manager
                # Notify to user
                @notification = Notification.create(user_id: @slot_assess.user.id, obj_user_id: approved_user.id, notification_type: "approve", obj_id: @slot_assess.id, obj_type: "slot", is_seen: false)
              
                # Notify to bod -> submit
                bod_users = User.where(is_bod: true).each do |bod_user|
                  notification = Notification.create(user_id: bod_user.id, obj_user_id: @slot_assess.user.id, notification_type: "submit", obj_id: @slot_assess.id, obj_type: "slot", is_seen: false)
                end
              end

              # for bod notification
              
              
              format.json { render json: @slot_assess }
            else
              format.json { render json: @slot_assess.errors.messages, status: :unprocessable_entity }
            end
          end
        end

      when "approve_other_subject_detail"
        respond_to do |format|
          @other_subject_assess = OtherSubjectAssess.find(params[:data])
          approved_user = User.find(params[:approved_user_id])
          is_bod = params[:role]

          unless is_bod.eql?("") #is bod
            p "Bod"
            if @other_subject_assess.update_attributes(status: "Passed", approved_user_id: approved_user.id, score: params[:score], is_notified: false)
              @notification2 = Notification.create(user_id: @other_subject_assess.user.id, obj_user_id: approved_user.id, notification_type: "approve", obj_id: @other_subject_assess.id, obj_type: "other_subject", is_seen: false)
              format.json { render json: @other_subject_assess }
            else
              format.json { render json: @other_subject_assess.errors.messages, status: :unprocessable_entity }
            end
          else
            p "Manager"
            if @other_subject_assess.update_attributes(approved_user_id: approved_user.id, score: params[:score], is_notified: true)
              
              # for teamleader notification
              if approved_user.is_team_leader
                # Notify to user
                notification1 = Notification.create(user_id: @other_subject_assess.user.id, obj_user_id: approved_user.id, obj_type: "other_subject", notification_type: "approve", obj_id: @other_subject_assess.id, is_seen: false)

                # Notify to manager -> submit
                manager = User.find(Department.find( @other_subject_assess.user.main_department_id).manager_id)
                notification2 = Notification.create(user_id: manager.id, obj_user_id: @other_subject_assess.user.id, notification_type: "submit", obj_id: @other_subject_assess.id, obj_type: "other_subject", is_seen: false)
              end

              # for manager notification
              if approved_user.is_manager
                # Notify to user
                @notification = Notification.create(user_id: @other_subject_assess.user.id, obj_user_id: approved_user.id, notification_type: "approve", obj_id: @other_subject_assess.id, obj_type: "other_subject", is_seen: false)
              
                # Notify to bod -> submit
                bod_users = User.where(is_bod: true).each do |bod_user|
                  notification = Notification.create(user_id: bod_user.id, obj_user_id: @other_subject_assess.user.id, notification_type: "submit", obj_id: @other_subject_assess.id, obj_type: "other_subject", is_seen: false)
                end
              end

              # for bod notification
              
              
              format.json { render json: @other_subject_assess }
            else
              format.json { render json: @other_subject_assess.errors.messages, status: :unprocessable_entity }
            end
          end          
        end

      when "reject_slot_in_timeline"
        respond_to do |format|
          @slot_assess = SlotAssess.find(params[:data])
          approved_user = User.find(params[:approved_user_id])
          is_bod = params[:role]

          unless is_bod.eql?("") #is bod
            p "Bod"
            if @slot_assess.update_attributes(status: "Not Passed", approved_user_id: params[:approved_user_id], is_notified: false)
              notification1 = Notification.create(user_id: @slot_assess.user.id, obj_user_id: approved_user.id, notification_type: "reject", obj_id: @slot_assess.id, obj_type: "slot", is_seen: false)
              notification2 = Notification.create(user_id: Department.find(@slot_assess.user.main_department_id).manager_id, obj_user_id: approved_user.id, notification_type: "return", obj_id: @slot_assess.id, obj_type: "slot", is_seen: false)
              notification3 = Notification.create(user_id: @slot_assess.user.team_leader_id, obj_user_id: approved_user.id, notification_type: "return", obj_id: @slot_assess.id, obj_type: "slot", is_seen: false)
              format.json { render json: @slot_assess }
            else
              format.json { render json: @slot_assess.errors.messages, status: :unprocessable_entity }
            end
          else
            p "Manager"
            if @slot_assess.update_attributes(approved_user_id: params[:approved_user_id], is_notified: false)
              # for team leader & user notification
              if approved_user.is_manager
                notification1 = Notification.create(user_id: @slot_assess.user.id, obj_user_id: approved_user.id, notification_type: "reject", obj_id: @slot_assess.id, obj_type: "slot", is_seen: false)
                notification3 = Notification.create(user_id: @slot_assess.user.team_leader_id, obj_user_id: approved_user.id, notification_type: "return", obj_id: @slot_assess.id, obj_type: "slot", is_seen: false)
              end

              # for user notification
              if approved_user.is_team_leader
                notification1 = Notification.create(user_id: @slot_assess.user.id, obj_user_id: approved_user.id, notification_type: "reject", obj_id: @slot_assess.id, obj_type: "slot", is_seen: false)
              end
              
              format.json { render json: @slot_assess }
            else
              format.json { render json: @slot_assess.errors.messages, status: :unprocessable_entity }
            end
          end
        end
        
      when "reject_slot_detail"
        respond_to do |format|
          @slot_assess = SlotAssess.find(params[:data])
          value = params[:value] || 1
          approved_user = User.find(params[:approved_user_id])
          is_bod = params[:role]

          unless is_bod.eql?("") #is bod
            p "Bod"
            if @slot_assess.update_attributes(value: value, status: "Not Passed", approved_user_id: params[:approved_user_id], is_notified: false)
              notification1 = Notification.create(user_id: @slot_assess.user.id, obj_user_id: approved_user.id, notification_type: "reject", obj_id: @slot_assess.id, obj_type: "slot", is_seen: false)
              notification2 = Notification.create(user_id: Department.find(@slot_assess.user.main_department_id).manager_id, obj_user_id: approved_user.id, notification_type: "return", obj_id: @slot_assess.id, obj_type: "slot", is_seen: false)
              notification3 = Notification.create(user_id: @slot_assess.user.team_leader_id, obj_user_id: approved_user.id, notification_type: "return", obj_id: @slot_assess.id, obj_type: "slot", is_seen: false)
              format.json { render json: @slot_assess }
            else
              format.json { render json: @slot_assess.errors.messages, status: :unprocessable_entity }
            end
          else
            p "Manager"
            if @slot_assess.update_attributes(value: value, approved_user_id: params[:approved_user_id], is_notified: false)
              # for team leader & user notification
              if approved_user.is_manager
                notification1 = Notification.create(user_id: @slot_assess.user.id, obj_user_id: approved_user.id, notification_type: "reject", obj_id: @slot_assess.id, obj_type: "slot", is_seen: false)
                notification3 = Notification.create(user_id: @slot_assess.user.team_leader_id, obj_user_id: approved_user.id, notification_type: "return", obj_id: @slot_assess.id, obj_type: "slot", is_seen: false)
              end

              # for user notification
              if approved_user.is_team_leader
                notification1 = Notification.create(user_id: @slot_assess.user.id, obj_user_id: approved_user.id, notification_type: "reject", obj_id: @slot_assess.id, obj_type: "slot", is_seen: false)
              end
              
              format.json { render json: @slot_assess }
            else
              format.json { render json: @slot_assess.errors.messages, status: :unprocessable_entity }
            end
          end
        end

      when "reject_other_subject_detail"
        respond_to do |format|
          @other_subject_assess = OtherSubjectAssess.find(params[:data])
          approved_user = User.find(params[:approved_user_id])
          is_bod = params[:role]

          unless is_bod.eql?("") #is bod
            p "Bod"
            if @other_subject_assess.update_attributes(status: "Not Passed", approved_user_id: params[:approved_user_id], is_notified: false)
              notification1 = Notification.create(user_id: @other_subject_assess.user.id, obj_user_id: approved_user.id, notification_type: "reject", obj_id: @other_subject_assess.id, obj_type: "other_subject", is_seen: false)
              notification2 = Notification.create(user_id: Department.find(@other_subject_assess.user.main_department_id).manager_id, obj_user_id: approved_user.id, notification_type: "return", obj_id: @other_subject_assess.id, obj_type: "other_subject", is_seen: false)
              notification3 = Notification.create(user_id: @other_subject_assess.user.team_leader_id, obj_user_id: approved_user.id, notification_type: "return", obj_id: @other_subject_assess.id, obj_type: "other_subject", is_seen: false)
              format.json { render json: @other_subject_assess }
            else
              format.json { render json: @other_subject_assess.errors.messages, status: :unprocessable_entity }
            end
          else
            p "Manager"
            if @other_subject_assess.update_attributes(approved_user_id: params[:approved_user_id], is_notified: false)
              # for team leader & user notification
              if approved_user.is_manager
                notification1 = Notification.create(user_id: @other_subject_assess.user.id, obj_user_id: approved_user.id, notification_type: "reject", obj_id: @other_subject_assess.id, obj_type: "other_subject", is_seen: false)
                notification3 = Notification.create(user_id: @other_subject_assess.user.team_leader_id, obj_user_id: approved_user.id, notification_type: "return", obj_id: @other_subject_assess.id, obj_type: "other_subject", is_seen: false)
              end

              # for user notification
              if approved_user.is_team_leader
                notification1 = Notification.create(user_id: @other_subject_assess.user.id, obj_user_id: approved_user.id, notification_type: "reject", obj_id: @other_subject_assess.id, obj_type: "other_subject", is_seen: false)
              end
              
              format.json { render json: @other_subject_assess }
            else
              format.json { render json: @other_subject_assess.errors.messages, status: :unprocessable_entity }
            end
          end      
        end

      when "withdraw_slot_detail"
        respond_to do |format|
          @slot_assess = SlotAssess.find(params[:data])
          @user = User.find(@slot_assess.user.id)

          
          if @user.team_leader_id

            @notification = Notification.where(user_id: @user.team_leader_id, obj_user_id: @user.id, obj_id: @slot_assess.id, obj_type: "slot", notification_type: "submit").order("created_at desc").first
            if @notification
              if @notification.destroy
                @slot_assess.update_attributes(is_notified: false)
                format.json { render json: @slot_assess }
              else
                format.json { render json: @slot_assess.errors.messages, status: :unprocessable_entity }
              end
            else
              format.text { render text: "Can't withdraw slot assess without having been notified yet."}
            end
          else
            format.text { render text: "This user's team leader is not availble. Please contact your Administrator to resolve."}
          end

        end

        when "withdraw_other_subject_detail"
        respond_to do |format|
          @other_subject_assesses = OtherSubjectAssess.find(params[:data])
          @user = User.find(@other_subject_assesses.user.id)

          
          if @user.team_leader_id
            @notification = Notification.where(user_id: @user.team_leader_id, obj_user_id: @user.id, obj_id: @other_subject_assesses.id, obj_type: "other_subject", notification_type: "submit").order("created_at desc").first
            if @notification
              if @notification.destroy
                @other_subject_assesses.update_attributes(is_notified: false)
                format.json { render json: @other_subject_assesses }
              else
                format.json { render json: @other_subject_assesses.errors.messages, status: :unprocessable_entity }
              end
            else
              format.text { render text: "Can't withdraw other subject assess without having been notified yet."}
            end
          else
            format.text { render text: "This user's team leader is not availble. Please contact your Administrator to resolve."}
          end

        end

      when "notify_for_detail"
        respond_to do |format|
          @slot_assess = SlotAssess.find(params[:data])
          if @slot_assess.self_value
            @user = User.find(@slot_assess.user.id)

            if @user.team_leader_id
              @notification = Notification.new(user_id: @user.team_leader_id, obj_user_id: @user.id, notification_type: "submit", obj_id: @slot_assess.id, obj_type: "slot", is_seen: false)
              if @notification.save
                @slot_assess.update_attributes(is_notified: true)
                format.json { render json: @slot_assess }
              else
                format.json { render json: @slot_assess.errors.messages, status: :unprocessable_entity }
              end
            else
              format.text { render text: "This user's team leader is not availble. Please contact your Administrator to resolve."}
            end
          else
            format.text { render text: "Please add your self assessment before notify to your manager"}
          end

        end

      when "notify_for_other_subject_detail"
        respond_to do |format|
          @other_subject_assess = OtherSubjectAssess.find(params[:data])
          if @other_subject_assess.self_score
            @user = User.find(@other_subject_assess.user.id)

            if @user.team_leader_id
              @notification = Notification.new(user_id: @user.team_leader_id, obj_user_id: @user.id, notification_type: "submit", obj_id: @other_subject_assess.id, obj_type: "other_subject", is_seen: false)
              if @notification.save
                @other_subject_assess.update_attributes(is_notified: true)
                format.json { render json: @other_subject_assess }
              else
                format.json { render json: @other_subject_assess.errors.messages, status: :unprocessable_entity }
              end
            else
              format.text { render text: "This user's team leader is not availble. Please contact your Administrator to resolve."}
            end
          else
            format.text { render text: "Please add your assessment result before notify to your manager"}
          end

        end

      when "update_notification_is_seen"
        notification_type = []
        notification_type.push(params[:notification_type])
        if params[:notification_type] == "approve"
          notification_type.push("submit")
        end

        if params[:notification_type] == "reject"
          notification_type.push("return")
        end

        @user = User.find(params[:data])
        rs = false
        respond_to do |format|
          if @user.notifications.where(notification_type: notification_type).length > 0
            @user.notifications.where(notification_type: notification_type).each do |notification|
              if notification.update_attributes(is_seen: true)
                rs = true
              else
                rs = false
              end

              unless rs
                format.json { render json: @user.errors.messages, status: :unprocessable_entity  }
              end
            end

            if rs
              format.json { render json: @user }
            end
          else
            format.json { render json: @user }
          end

        end


      end

  end


  ##
  # This function to calculate Title for user
  #Parameters::
  # * (json) *params*: Params for action
  # Inspec the List of Competency, List of Level and List of Slot to check if slot is assessed and aprroved (status  = true)
  # Based on the CDS System in Larion Computing, calculate to find Current Title for user
  # 
  # 
  #Return::
  # * (json) status: ok=>done
  #*Author*:: DangNH
  #
  def calculate_title(id)
        @user = User.find(id)
        @passed_slots = @user.slot_assesses.where(status: "Passed")
        array = []
        next_competency_passed = 0
        hash = {}

        # Competency
        Competency.order("id").each do |c|
          max_value = 0
          p c.name
          rank = ""
          pre_level = "0"
          value_of_level_raking = 0

          # Level        
          c.levels.order("id").each do |level|
            total_sum = 0
            passed_count = 0
            not_passed_count = 0
            assessed_all_slots = true
            number_of_slot = level.slots.count
            pass_level_point = (number_of_slot*5)/2

            # Slot
            level.slots.order("id").each do |slot|
              if slot.slot_assesses.where(user_id: @user.id, status: "Passed").length > 0
                score = get_max_score(slot.slot_assesses.where(user_id: @user.id, status: "Passed"))
                passed_count += 1
                total_sum += score.to_i

              elsif slot.slot_assesses.where(user_id: @user.id, status: "Not Passed").length > 0
                score = get_max_score(slot.slot_assesses.where(user_id: @user.id, status: "Not Passed"))
                not_passed_count += 1
                total_sum += score.to_i
              else
                assessed_all_slots = false
              end
            end
            #  End Slot

            if passed_count == number_of_slot
              rank = level.name.gsub("Level ", "")
            elsif passed_count > 0 && passed_count < number_of_slot && total_sum >= pass_level_point && assessed_all_slots
              rank = "++" + level.name   .gsub("Level ", "")  
            elsif passed_count > 0 && passed_count < number_of_slot
              rank = pre_level.gsub("Level ", "") + "-" + level.name.gsub("Level ", "")       
            end

            pre_level = level.name.gsub("Level ", "")
            
            rank = "0" if rank == ""
            value_of_level_raking = calculate_level_raking(rank) if rank != ""
            
            # p rank
            # p value_of_level_raking
            # p "================"
            if rank != "0"
              if c.titles_competencies.where("value < ?", value_of_level_raking).length > 0
                max_value = c.titles_competencies.where("value < ?", value_of_level_raking)[0].title.value
              end

              if c.titles_competencies.where("value > ?", value_of_level_raking).length > 0
                max_value = c.titles_competencies.where("value > ?", value_of_level_raking)[0].title.value
              end   

              if c.titles_competencies.where("value = ?", value_of_level_raking).length > 0
                max_value = c.titles_competencies.where("value = ?", value_of_level_raking)[0].title.value
              end
            else
              max_value = 0
            end
                   
          end
          #  End Level

          hash[c.name] = rank
          array.push(max_value)
        end

        # p hash
        # p array


        # hash, array = calculate_ranking_of_competency(id)
        # End Competency

        min = array.min

        # p min, "========================="

        flag_da = false

        while min > 0 && min <= 6
          if min <= 3
            title = Title.where(value: min).first
          else
            title = Title.where(value: min, career_path: @user.career_path).first
          end

          # p title

          #  If user's competency is not passed to get any title, code will stop
          if title
            pass_all_other_subjects = true
            other_subject_assesses = @user.other_subject_assesses

            # Get list scoring belongs to title's id
            TitleGroupsOtherSubject.where(title_id: title.id).each do |to|
              other_subject_assess = other_subject_assesses.find_by_other_subject_id(to.other_subject_id)
              unless other_subject_assess.score.eql?(nil) 
                #  If all Other Subject Assessed by user have score >= scoring in of each Other Subject in Title -> pass
                if other_subject_assess.score >= to.scoring && other_subject_assess.status.eql?("Passed")
                  flag_da = false
                else
                  pass_all_other_subjects = false
                  flag_da = true
                  min -= 1
                  break

                end
              else
                pass_all_other_subjects = false
              end
            end


            if flag_da
              next
            end

            # p pass_all_other_subjects

            if pass_all_other_subjects
              check_new_user = false
              pass_competency_count = 0
              # p "Array: #{array}"
              for i in 0...array.length
                # p "#{array[i]} -------- #{min}"
                array[i] = array[i] - min
                if array[i] > 0
                  pass_competency_count += 1
                  check_new_user = true
                else
                  check_new_user = true
                end

              end          

              # Check rank for each Title
              if check_new_user
                rank_id = title.ranks.first.id
                if pass_competency_count > 0
                  title.ranks.each do |r|
                    if pass_competency_count >= r.number_competencies_next_level
                      rank_id = r.id
                    end
                  end
                else
                  rank_id = title.ranks.first.id
                end

                # p rank_id

                @current_title = @user.current_title
                @current_title.update_attributes(rank_id: rank_id)
                break
              else
                break
              end
              
            else
              break
            end

          end
        end
    return hash
  end

  def view_statistic
    @user = User.find(params[:data])
    p @user, "====================="
    render :layout => false
  end

  private

  def calculate_ranking_of_competency(id)
    @user = User.find(id)
    @passed_slots = @user.slot_assesses.where(status: "Passed")
    array = []
    next_competency_passed = 0
    hash = {}

    # Competency
    # Competency
    Competency.order("id").each do |c|
      max_value = 0
      p c.name
      rank = ""
      pre_level = "0"
      value_of_level_raking = 0

      # Level        
      c.levels.order("id").each do |level|
        total_sum = 0
        passed_count = 0
        not_passed_count = 0
        assessed_all_slots = true
        number_of_slot = level.slots.count
        pass_level_point = (number_of_slot*5)/2

        # Slot
        level.slots.order("id").each do |slot|
          if slot.slot_assesses.where(user_id: @user.id, status: "Passed").length > 0
            score = get_max_score(slot.slot_assesses.where(user_id: @user.id, status: "Passed"))
            passed_count += 1
            total_sum += score.to_i

          elsif slot.slot_assesses.where(user_id: @user.id, status: "Not Passed").length > 0
            score = get_max_score(slot.slot_assesses.where(user_id: @user.id, status: "Not Passed"))
            not_passed_count += 1
            total_sum += score.to_i
          else
            assessed_all_slots = false
          end
        end
        #  End Slot

        if passed_count == number_of_slot
          rank = level.name.gsub("Level ", "")
        elsif passed_count > 0 && passed_count < number_of_slot && total_sum >= pass_level_point && assessed_all_slots
          rank = "++" + level.name   .gsub("Level ", "")  
        elsif passed_count > 0 && passed_count < number_of_slot
          rank = pre_level.gsub("Level ", "") + "-" + level.name.gsub("Level ", "")       
        end

        pre_level = level.name.gsub("Level ", "")
        
        value_of_level_raking = calculate_level_raking(rank) if rank != ""
        
        if c.titles_competencies.where("value < ?", value_of_level_raking).length > 0
          max_value = c.titles_competencies.where("value < ?", value_of_level_raking)[0].title.value
        end   

        if c.titles_competencies.where("value = ?", value_of_level_raking).length > 0
          max_value = c.titles_competencies.where("value = ?", value_of_level_raking)[0].title.value
        end
               
      end
      #  End Level

      hash[c.name] = rank
      array.push(max_value)
    end

    return hash, array
  end

  ##
  # Check the current user is higher or equal position with user
  # @author DangNH
  ##
  def check_higher_position(user, current_user)
    rs = false
    if user.eql?(current_user)
      rs = true
      return rs
    end

    if user.team_leader_id == current_user.id
      rs = true
      return rs
    end

    array = user.departments.map(&:id)
    if Department.where("id in (?)", array).map(&:manager_id).include?(current_user.id)
      rs = true
      return rs
    end

    if current_user.is_bod || current_user.is_hr
      rs = true
      return rs
    end
  end

  ##
  # Get max score form list of score
  # @author DangNH
  ##
  def get_max_score(list)
    max = list[0].value
    list.each do |l|
      max = l.value if l.value > max
    end
    return max
  end

  ##
  # Calculate level ranking for user
  # @author DangNH
  ##
  def calculate_level_raking(rank)
    value = 0
    if rank.include?("-")
      value = rank.split("-")[0].to_f + 0.5
      # if value = rank.split("-")[0].to_i == 0
      #   value = 0.5
      # elsif rank.split("-")[0].to_i == 1
      #   value = 1.5
      # else
      #   value = rank.split("-")[1].to_i / rank.split("-")[0].to_i
      # end   
    elsif rank.include?("++")
      value = (rank.gsub("++","").to_i - 1) + 0.8
    else
      value = rank.to_i
    end
    
    return value
  end

  ##
  # Render errors when import list of user
  # @author DatPB
  ##
  def render_error(field = nil, opts = {})
    opts.merge! :scope => [:error, :importing]

    flash[:alert] = t(field, opts) if field
    params[:format] = "html"
    # redirect_to new_list_users_organization_users_path(current_user.organization_id)
    redirect_to user_pa_organization_user_path(current_user.organization_id, current_user.id)
  end

  ##
  # Automatically create Instance & InstanceTerm for use if user is first login when Term is intime
  #Parameters::
  # * (integer) *id*: Term's id
  # * (integer) *id*: User's id
  #Return::
  # * (json) status: ok=>done
  #*Author*:: DangNH
  #
  def create_slot_assess_for_user(user_id)
    user = User.find(user_id)

    unless user.current_title
      CurrentTitle.create(user_id: user.id)
    end

    if user.slot_assesses.length == 0
      Slot.order("id").each do |slot|
        SlotAssess.create(user_id: user.id, slot_id: slot.id, competency_name: slot.level.competency.name, level_name: slot.level.name, slot_name: slot.name, status: "Not Added Yet", is_notified: false)
      end
    end

    if user.other_subject_assesses.length == 0
      OtherSubject.order("id").each do |os|
        OtherSubjectAssess.create(user_id: user.id, other_subject_id: os.id, status: "Not Assessed Yet", other_subject_name: os.name, is_notified: false)
      end
    end
  end

 
end