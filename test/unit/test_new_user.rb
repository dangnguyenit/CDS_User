require File.expand_path('../../../test/unit/test_base.rb', __FILE__)

class TestNewUser < TestBase

  def test_new_right_user
     login("admin")
     #Click menu user
     @ff.link(id: "menu_user").click
     #Click menu user
     @ff.button(:value, 'Add User').click
     @ff.text_field(:name => "user[username]").set(TestSetting.users.new_user.username + Random.rand.to_s)
     @ff.text_field(:name => "user[first_name]").set(TestSetting.users.new_user.first_name)
     @ff.text_field(:name => "user[last_name]").set(TestSetting.users.new_user.last_name)
     @ff.text_field(:name => "user[email]").set(Random.rand.to_s + TestSetting.users.new_user.email)
     @ff.text_field(:name => "user[password]").set(TestSetting.users.new_user.password)
     @ff.text_field(:name => "user[password_confirmation]").set(TestSetting.users.new_user.password_confirmation)
     @ff.checkbox(:name => "user_groups[]",:value => "1").set
     @ff.button(:value, 'Save').click

     #sleep 1 until @browser.text.include? "Available User Groups"
     
     assert(@ff.text.include?("List of Users") == true, 'Can\'t redirect to users_path')
     assert(@ff.text.include?("New User") == false, 'Faile create right user')
  end
  
  def test_new_wrong_user
     login("admin")
     #Click menu user
     @ff.link(id: "menu_user").click
     #Click add user
     @ff.button(:value, 'Add User').click
     @ff.text_field(:name => "user[username]").clear
     @ff.text_field(:name => "user[first_name]").clear
     @ff.text_field(:name => "user[last_name]").clear
     @ff.text_field(:name => "user[email]").clear
     @ff.text_field(:name => "user[password]").clear
     @ff.text_field(:name => "user[password_confirmation]").clear
     @ff.checkbox(:name => "user_groups[]",:value => "1").set
     @ff.button(:value, 'Save').click
     
     assert(@ff.label(:for => 'user_username').exist?, 'No label for warning blank username')
     assert(@ff.label(:for => 'user_username').text == 'Enter User Name', 'Check blank username')
     assert(@ff.label(:for => 'user_first_name').exist?, 'No label for warning blank first_name')
     assert(@ff.label(:for => 'user_first_name').text == 'Enter First Name', 'Check blank first_name')
     assert(@ff.label(:for => 'user_last_name').exist?, 'No label for warning blank last_name')
     assert(@ff.label(:for => 'user_email').text == 'Enter Email', 'Check blank email')
     assert(@ff.label(:for => 'user_email').exist?, 'No label for warning blank email')
     assert(@ff.label(:for => 'user_last_name').text == 'Enter Last Name', 'Check blank last_name')
     assert(@ff.label(:for => 'user_password').exist?, 'No label for warning blank password')
     assert(@ff.label(:for => 'user_password').text == 'Enter Password', 'Check blank password')
  end
  
  def test_new_exist_user
     string_random = Random.rand.to_s
     login("admin")
     #Click menu user
     @ff.link(id: "menu_user").click
     #Click add user
     @ff.button(:value, 'Add User').click
     
     @ff.text_field(:name => "user[username]").set(TestSetting.users.new_user.username + string_random)
     @ff.text_field(:name => "user[first_name]").set(TestSetting.users.new_user.first_name)
     @ff.text_field(:name => "user[last_name]").set(TestSetting.users.new_user.last_name)
     @ff.text_field(:name => "user[email]").set(Random.rand.to_s + TestSetting.users.new_user.email)
     @ff.text_field(:name => "user[password]").set(TestSetting.users.new_user.password)
     @ff.text_field(:name => "user[password_confirmation]").set(TestSetting.users.new_user.password_confirmation)
     @ff.checkbox(:name => "user_groups[]",:value => "1").set
     @ff.button(:value, 'Save').click
     
     @ff.button(:value, 'Add User').click
     #Create a user have existed uername
     @ff.text_field(:name => "user[username]").set(TestSetting.users.new_user.username + string_random)
     @ff.text_field(:name => "user[first_name]").set(TestSetting.users.new_user.first_name)
     @ff.text_field(:name => "user[last_name]").set(TestSetting.users.new_user.last_name)
     @ff.text_field(:name => "user[email]").set(Random.rand.to_s + TestSetting.users.new_user.email)
     @ff.text_field(:name => "user[password]").set(TestSetting.users.new_user.password)
     @ff.text_field(:name => "user[password_confirmation]").set(TestSetting.users.new_user.password_confirmation)
     @ff.checkbox(:name => "user_groups[]",:value => "1").set
     @ff.button(:value, 'Save').click
     
     assert(@ff.text.include?('Someone already has that user name. Try another?'), 'Check exist username')
  end
  
  def test_new_exist_email
     string_random = Random.rand.to_s
     login("admin")
     #Click menu user
     @ff.link(id: "menu_user").click
     #Click add user
     @ff.button(:value, 'Add User').click
     
     @ff.text_field(:name => "user[username]").set(TestSetting.users.new_user.username + Random.rand.to_s)
     @ff.text_field(:name => "user[first_name]").set(TestSetting.users.new_user.first_name)
     @ff.text_field(:name => "user[last_name]").set(TestSetting.users.new_user.last_name)
     @ff.text_field(:name => "user[email]").set(string_random+ TestSetting.users.new_user.email)
     @ff.text_field(:name => "user[password]").set(TestSetting.users.new_user.password)
     @ff.text_field(:name => "user[password_confirmation]").set(TestSetting.users.new_user.password_confirmation)
     @ff.checkbox(:name => "user_groups[]",:value => "1").set
     @ff.button(:value, 'Save').click
     
     @ff.button(:value, 'Add User').click
     #Create a user have existed uername
     @ff.text_field(:name => "user[username]").set(TestSetting.users.new_user.username + Random.rand.to_s)
     @ff.text_field(:name => "user[first_name]").set(TestSetting.users.new_user.first_name)
     @ff.text_field(:name => "user[last_name]").set(TestSetting.users.new_user.last_name)
     @ff.text_field(:name => "user[email]").set(string_random+ TestSetting.users.new_user.email)
     @ff.text_field(:name => "user[password]").set(TestSetting.users.new_user.password)
     @ff.text_field(:name => "user[password_confirmation]").set(TestSetting.users.new_user.password_confirmation)
     @ff.checkbox(:name => "user_groups[]",:value => "1").set
     @ff.button(:value, 'Save').click
     
     assert(@ff.text.include?('Email has already been taken. Try another?'), 'Check exist email')
  end
  
end