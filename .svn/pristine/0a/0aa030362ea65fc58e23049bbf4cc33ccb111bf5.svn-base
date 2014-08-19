# This module is used to manager permissions
# History: June 06, 2013
# By NamTV

class Ability
  include CanCan::Ability

  ##
  #Get user list except an user with specify ID
  #Parameters::
  # * (User) *user*: initialize a user with his permissions
  #Return::
  # * (json) Matched user list with paging and number all rows are finded
  #*Author*:: NamTV
  def initialize(user,org_id)

    user ||= User.new # guest user (not logged in)

    # permission view org for any user
    can :show, Organization, :id => user.organization_id

    # all permission for super admin
    if user.admin? && user.organization.super_org?
      can :manage, :all
      return
    end

    # Allow user == admin of group manage User,Group,Log
    if user.admin? && user.organization_id == org_id
      can :manage, User
      can :manage, UserGroup
      can :index, Activity
      return
    end
    # Allow user to view, edit himself
    alias_action :read, :update, :to => :manage_self
    #can :manage_self, User, :is_deleted => false, :id => current_user.id

    # check groups is active
    @groups = user.user_groups.where(:is_active => true)
    @permission =[]
    #only set permissions for active groups
    @groups.each do |group|
      @permission.concat(group.permissions)
    end
    # not have duplicated permissions
    @permission.uniq!

    @permission.each do |p|
      case p.code
      # Add additional ability here
      when "full_organization_management"
        can :manage, Organization
      when "full_group_management"
        can :manage, UserGroup
      when "full_user_management"
        can :manage, User
      when "full_department_management"
        can :manage, Department
      when "full_term_management"
        can :manage, Term
      when "view_log"
        can :index, Activity
      when "view_organization"
        can [:index, :show], Organization
      when "view_group"
        can [:index, :show], UserGroup
      when "view_user"
        can [:index, :show], User
      when "user_pa"
        can [:notification_reject, :notification_approve, :notification_cmt, :other_subject_detail, :upload_photo, :recently_added_slider, :slot_detail, :recently_not_added_slot, :timeline, :home, :team_member, :upload_avatar, :user_pa, :recently_added, :current_status, :about, :all_other_subject, :all_slot, :short_term_objective, :comments, :remove_evidence, :action_instances_tem], User
      when "view_department"
        can [:index, :show], Department
      when "view_term"
        can [:index, :show], Term
      end
    end
  end
end
