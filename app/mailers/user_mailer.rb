class UserMailer < ActionMailer::Base
  default from: "thuylc@elarion.com"

  def get_new_title_email(user)
  	@user = user
  	mail(to: @user.email, subject: "[Upgrated Title] #{@user.full_name} has been upgrate his/her title")
  end
end
