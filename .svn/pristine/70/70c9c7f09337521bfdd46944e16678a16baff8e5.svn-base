require File.expand_path('../../../test/unit/test_base.rb', __FILE__)

class TestLogin < TestBase

  def test_have_elements

    # Check if page has all needed elements
    assert(@ff.text_field(name: 'user[username]').exist? == true, 'Missing User Name field')
    assert(@ff.text_field(name: 'user[password]').exist? == true, 'Missing Password field')
    assert(@ff.button(name: 'commit').exist? == true, 'Missing Save button')
    assert(@ff.checkbox(name: 'user[remember_me]').exist? == true, 'Missing Remember me checkbox')

  end

  def test_right_login
    #Enter right information
    @ff.text_field(:name => "user[username]").set(TestSetting.users.admin.username)
    @ff.text_field(:name => "user[password]").set(TestSetting.users.admin.password)

    #Click Sign in
    @ff.button(:name, 'commit').click
    assert(@ff.link(text: 'Logout').exist? == true, 'Missing "Logout" link')
    assert(@ff.link(text: 'Login').exist? == false, 'There still has "Login" link')

  end

  def test_wrong_login
    #Enter right information
    @ff.text_field(:name => "user[username]").set(TestSetting.users.wrong.username)
    @ff.text_field(:name => "user[password]").set(TestSetting.users.wrong.password)

    #Click Sign in
    @ff.button(:name, 'commit').click
    assert(@ff.text.include?('The User Name or Password you entered is incorrect.')  == true, 'Check Wrong information')

  end

  #Test warning when leave blank email and password
  def test_login_with_blank_information
      #Leave email and password to be empty
      @ff.text_field(:name => "user[username]", :id => "user_username").clear
      @ff.text_field(:name => "user[password]", :id => "user_password").clear
      #click sign in
      @ff.button(name: 'commit').click
      #test email and password
      assert(@ff.label(:for => 'user_username').exist? == true, 'No label for warning blank username')
      assert(@ff.label(:for => 'user_username').text == 'Please enter username.', 'Check blank email')
      assert(@ff.label(:for => 'user_password').exist? == true, 'No label for warning blank password')
      assert(@ff.label(:for => 'user_password').text == 'Please enter password.', 'Check blank password')
  end

end