require File.expand_path('../../../test/unit/test_base.rb', __FILE__)

class TestUser < TestBase
  def test_list_no_user
     login("admin")
     #Click menu user
     @ff.link(id: "menu_user").click
     
     assert(@ff.text.include?("List of Users"), 'Can\'t redirect to users_path')
     assert(@ff.button(:value, 'Add User').exist?,"No button for warning create user")
  end
  
  def test_list_users
     login("admin")
     #Click menu user
     @ff.link(id: "menu_user").click
     
     @ff.button(:value, 'Add User').click
     
     @ff.text_field(:name => "user[username]").set(TestSetting.users.new_user.username + Random.rand.to_s)
     @ff.text_field(:name => "user[first_name]").set(TestSetting.users.new_user.first_name)
     @ff.text_field(:name => "user[last_name]").set(TestSetting.users.new_user.last_name)
     @ff.text_field(:name => "user[password]").set(TestSetting.users.new_user.password)
     @ff.text_field(:name => "user[password_confirmation]").set(TestSetting.users.new_user.password_confirmation)
     @ff.checkbox(:name => "user_groups[]",:value => "1").set
     @ff.button(:value, 'Save').click
     
     full_name = TestSetting.users.new_user.first_name + " " +TestSetting.users.new_user.last_name
     
     assert(@ff.link(text: "Delete").exist?,"No link for delete user")
     assert(@ff.link(text: full_name).exist?,"No link for edit user")
  end
end
