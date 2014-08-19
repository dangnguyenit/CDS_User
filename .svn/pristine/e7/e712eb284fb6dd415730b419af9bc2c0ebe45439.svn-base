# This controller is used to set new password when someone forgot
# History: June 06, 2013
# By NamTV

class PasswordsController < Devise::PasswordsController
  layout false
  skip_before_filter :require_no_authentication, :only => [:create]
  skip_authorize_resource

  ##
  #Action Name:: create
  #Parameters:: N/A
  #Return:: Return the response of get new password request
  #*Author*:: NamTV
  #----------------------------------------------------------------------------
  def create
    @user = User.find_by_email(params[:email])
    respond_to do |format|
      if @user
        if @user.send_reset_password_instructions
          format.json { render json: @user }
        else
          format.text { render text: "Email can't be sent to your email address. Please try again!", status: :unprocessable_entity }
        end
      else
        format.text { render text: "Could not find user with email", status: :unprocessable_entity }
      end
    end

  end


end
