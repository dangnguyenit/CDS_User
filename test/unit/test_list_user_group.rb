require File.expand_path('../../../test/unit/test_base.rb', __FILE__)

class TestUserGroup < TestBase
  def test_list_no_user
     login("admin")
     #Click menu user
     @ff.link(id: "menu_user_group").click
     
     assert(@ff.text.include?("List of Groups"), 'Can\'t redirect to users_path')
     assert(@ff.button(:value, 'Add Group').exist?,"No button for warning create user")
  end
  
  def test_list_users
     login("admin")
     #Click menu user
     @ff.link(id: "menu_user_group").click
     
     @ff.button(:value, 'Add Group').click
     
     name = TestSetting.groups.new_group.name + Random.rand.to_s
     @ff.text_field(:name => "user_group[name]").set(name)
     @ff.text_field(:name => "user_group[description]").set(TestSetting.groups.new_group.description)
     @ff.checkbox(:name => "permissions[]",:value => "1").set
     @ff.button(:value, 'Save').click
     
     assert(@ff.link(text: "Delete").exist?,"No link for delete group")
     assert(@ff.link(text: name).exist?,"No link for edit group")
  end
end
