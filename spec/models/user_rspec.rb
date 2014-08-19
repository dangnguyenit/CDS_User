require "spec_helper"

describe User do
  describe ".get_all_users_except_id" do
    context "get users except a normal user" do
      it "should return number of users" do
        normal_user = User.where(:is_admin => false).first
        users = User.get_all_users_except_id(normal_user.id,1,20,"",[])
        users["aaData"].size.should be User.count-2
        users["iTotalDisplayRecords"].should == User.count-2
      end
    end
    
    context "get users except admin user" do
      it "should return number of users" do
        admin_user = User.where(:is_admin => true).first
        users = User.get_all_users_except_id(admin_user.id,1,20,"",[])
        users["aaData"].size.should be User.count-1
        users["iTotalDisplayRecords"].should == User.count-1
      end
    end
    
    context "get users without except" do
      it "should return number of users" do
        users = User.get_all_users_except_id(0,1,20,"",[])
        users["aaData"].size.should be User.count-1
        users["iTotalDisplayRecords"].should == User.count-1
      end
    end
  end
  
  describe ".get_all_groups_from_user" do
    it "should return array of users" do
      user = User.find_by_id(1)
      user.user_groups.class.should be Array
    end
  end
  
  describe ".get_users_follow_page" do
    it "should return number of available users" do
      user_size = User.where(:is_admin => false).count # number of user except admin
      page = 2 # N.o of page
      page_size = 20 # number of users per a page
      num_available_page = user_size/page_size +1 # number of page from data
      # size of page from database (except admin and userself)
      size_of_page_except_admin_user = page*page_size <= user_size ? page_size-1 : user_size-(page-1)*page_size-1
      #number user on page that is expected
      num_available_user = (1..num_available_page).include?(page) ? size_of_page_except_admin_user : 0
      normal_user = User.where(:is_admin => false).first
      users = User.get_all_users_except_id(normal_user.id,page,page_size,"",[])
      users["aaData"].size.should be num_available_user
      users["iTotalDisplayRecords"].should == user_size-1
    end
  end
  
 end
    
