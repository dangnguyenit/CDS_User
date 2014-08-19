# This controller is used to register new user
# History: June 06, 2013
# By NamTV

class RegistrationsController < Devise::RegistrationsController
  ##
  #Override new of Devise::RegistrationsController
  #Parameters::
  #Return::
  # * page of register user include organization
  #*Author*:: PhuNd
  def new
    @organizations = Organization.get_all_orgs
    super
  end

  ##
  #Override create of Devise::RegistrationsController
  #Parameters::
  #Return::
  # * page of register if error and login if not error
  #*Author*:: DatPB
  def create
    if verify_recaptcha
      @organizations = Organization.get_all_orgs
      
      new_org = Organization.new(org_params)

      if new_org.save
        build_resource(user_params)
        if resource.save
          resource.organization_id = new_org.id
          resource.save

          new_org.after_create_org

          if resource.active_for_authentication?
            set_flash_message :notice, :signed_up if is_navigational_format?
            sign_up(user_params[:username], resource)
            respond_with resource, :location => after_sign_up_path_for(resource)
          else
            set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
            expire_session_data_after_sign_in!
            #respond_with resource, :location => after_inactive_sign_up_path_for(resource)
            redirect_to thank_you_sign_up_path
          end
        else
          clean_up_passwords resource
          new_org.before_destroy_org
          new_org.destroy
          
          respond_with resource
        end
      else #org errors
        build_resource
        clean_up_passwords(resource)
        new_org.errors.each do |attr, err|
          resource.errors.add(attr, err) unless resource.errors.include?(attr)
        end

        render :new
      end
    else
      build_resource
      clean_up_passwords(resource)
      flash.now[:error] = t("errors.messages.wrong_captcha")
      flash.delete :recaptcha_error
      @organizations = Organization.get_all_orgs
      render :new
    end
  end

  # This action render thanks you page after sign up successfully
  #
  #**Args* :
  # -+params+->
  #
  #*Written:* DatPB
  #
  #*Date:* July 22, 2013
  #
  #*Modified:*
  def thank_you_sign_up
    @sign_up_success = true
  end

  private

  # This method return params for organization
  #
  #**Args* :
  # -+params+->
  #
  #*Written:* DatPB
  #
  #*Date:* July 22, 2013
  #
  #*Modified:*
  def org_params
    params[:organization].except(:accept_the_term)
  end

  # This method return params for user
  #
  #**Args* :
  # -+params+->
  #
  #*Written:* DatPB
  #
  #*Date:* July 22, 2013
  #
  #*Modified:*
  def user_params
    #params[:user][:username] = params[:user][:username].downcase
    params[:user][:is_admin] = true

    params[:user]
  end
end