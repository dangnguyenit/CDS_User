# This controller is used to process and render home page
# History: June 06, 2013
# By NamTV

class HomeController < ApplicationController
  skip_authorize_resource

  ##
  #Get user list except an user with specify ID
  #Parameters::
  #Return::
  # * login page if !current_user and home#index if current_user
  #*Author*:: NamTV
  def index
    redirect_to new_user_session_path
    # if !current_user
    #   flash[:notice] = flash[:notice]
    #   redirect_to new_user_session_path
    #   return
    # end
    # redirect_to after_sign_in_path_for(current_user)
  end
end