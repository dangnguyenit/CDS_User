require File.expand_path('../../../test/unit/test_base.rb', __FILE__)

class TestHomePage < TestBase

  def test_admin_user_have_elements
    login("admin")
    assert(@ff.link(href: '/users').exist?, "Missing User Management link.")
    assert(@ff.link(href: '/user_groups').exist?, "Missing Group Management link.")
  end

  def test_usr_user_have_elements
    login("user_mgt")
    assert(@ff.link(href: '/users').exist?, "Missing User Management link.")
    assert(!@ff.link(href: '/user_groups').exist?, "Wrong Group Management link.")
  end

  def test_group_user_have_elements
    login("group_mgt")
    assert(!@ff.link(href: '/users').exist?, "Wrong User Management link.")
    assert(@ff.link(href: '/user_groups').exist?, "Missing Group Management link.")
  end

  def test_none_user_have_elements
    login("none")
    assert(!@ff.link(href: '/users').exist?, "Wrong User Management link.")
    assert(!@ff.link(href: '/user_groups').exist?, "Wrong Group Management link.")
  end
end