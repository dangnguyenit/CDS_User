# This controller is used as parent controller

# History: June 06, 2013
# By NamTV

class ApplicationController < ActionController::Base

  include PublicActivity::StoreController
  protect_from_forgery
  authorize_resource :unless => :devise_controller?


  rescue_from CanCan::AccessDenied do |exception|
    render :file => "#{Rails.root}/public/401.html", :status => 401, :layout => false
  end

  private

  ##
  #Method Name:: support create permissions
  #Parameters::
  #Return:: current user and current organization id
  #*Author*:: NamTV
  #---------------------------------------------------------------------
  def current_ability
    @current_ability ||= Ability.new(current_user, session[:org_id])
  end

  ##
  #Method Name:: after_sign_in_path_for
  #Parameters:: resource from devise
  #Return:: Path after signin
  #*Author*:: NamTV
  #----------------------------------------------------------------------------
  def after_sign_in_path_for(resource)
    resource.update_attributes(cached_failed_attempts: 0, failed_attempts: 0)
    organization = resource.organization
    session[:org_id] = resource.organization_id
    (resource.admin? && organization.super_org?) ? user_pa_organization_user_path(organization, resource.id) : user_pa_organization_user_path(organization, resource.id)
  end

  ##
  #Method Name:: after_sign_out_path_for
  #Parameters:: resource from devise
  #Return:: Return the new session path
  #*Author*:: NamTV & DangNH
  #----------------------------------------------------------------------------
  def after_sign_out_path_for(resource)
    session[:org] = nil
    new_user_session_path
  end

end
