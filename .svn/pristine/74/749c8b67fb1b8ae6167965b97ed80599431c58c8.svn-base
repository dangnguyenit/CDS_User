require File.expand_path('../../../test/unit/test_base.rb', __FILE__)

class TestNewUserGroup < TestBase

  def test_new_right_user_group
     login("admin")
     #Click menu user group
     @ff.link(id: "menu_user_group").click
     
     #Click menu user group
     @ff.button(:value, 'Add Group').click
     name = TestSetting.groups.new_group.name + Random.rand.to_s
     @ff.text_field(:name => "user_group[name]").set(name)
     @ff.text_field(:name => "user_group[description]").set(TestSetting.groups.new_group.description)
     @ff.checkbox(:name => "permissions[]",:value => "1").set
     @ff.button(:value, 'Save').click

     #sleep 1 until @browser.text.include? "Available User Groups"
     
     assert(@ff.link(text: "Delete").exist?,"No link for delete group")
     assert(@ff.text.include?("New Group") == false, 'Fail create right user_group')
  end
  
  def test_new_wrong_user_group
     login("admin")
     #Click menu user
     @ff.link(id: "menu_user_group").click
     #Click add user
     @ff.button(:value, 'Add Group').click
     @ff.text_field(:name => "user_group[name]").clear
     @ff.text_field(:name => "user_group[description]").clear
     @ff.checkbox(:name => "permissions[]",:value => "1").set
     @ff.button(:value, 'Save').click
     
     assert(@ff.label(:for => 'user_group_name').exist?, 'No label for warning blank group name.')
     assert(@ff.label(:for => 'user_group_name').text == 'Please enter group name.', 'Check blank group name')
     assert(@ff.label(:for => 'user_group_description').exist?, 'No label for warning blank description')
     assert(@ff.label(:for => 'user_group_description').text == 'Please enter description.', 'Check blank description')
     
  end
  
  def test_new_exist_user_group
     login("admin")
     #Click menu user group
     @ff.link(id: "menu_user_group").click
     
     #Click menu user group
     @ff.button(:value, 'Add Group').click
     name = TestSetting.groups.new_group.name + Random.rand.to_s
     @ff.text_field(:name => "user_group[name]").set(name)
     @ff.text_field(:name => "user_group[description]").set(TestSetting.groups.new_group.description)
     @ff.checkbox(:name => "permissions[]",:value => "1").set
     @ff.button(:value, 'Save').click
     
     @ff.button(:value, 'Add Group').click
     #Create a user have existed uername
     @ff.text_field(:name => "user_group[name]").set(name)
     @ff.text_field(:name => "user_group[description]").set(TestSetting.groups.new_group.description)
     @ff.checkbox(:name => "permissions[]",:value => "1").set
     @ff.button(:value, 'Save').click
     
     assert(@ff.text.include?('Group Name has already existed . Try another?'), 'Check exist group name')
  end
  
end