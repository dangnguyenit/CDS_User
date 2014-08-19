# This controller is overrirded from Devise::ConfirmationsController
# History: June 06, 2013
# By NamTV
class ConfirmationsController < Devise::ConfirmationsController

  ##
  #Override create of Devise::ConfirmationsController
  #Parameters::
  #Return::
  # * page of confrimation page if error and send mail if not error
  #*Author*:: NamTV
  def create
      if verify_recaptcha
        super
      else
        build_resource
        clean_up_passwords(resource)
        flash.now[:error] = t("errors.messages.wrong_captcha")
        flash.delete :recaptcha_error
        render :new
      end
    end
end