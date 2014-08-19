require "spec_helper"

describe UserGroup do
  
  describe ".get_all_user_groups" do
    context "get user_groups except default group" do
      it "should return number of groups" do
        admin_group = UserGroup.where(:name => "Administrator").first
        groups = UserGroup.get_all_user_groups(1,20,"",[])
        groups["aaData"].size.should be UserGroup.count-1
        groups["aaData"].size.should == groups["iTotalDisplayRecords"]
      end
    end
  end
  
  describe ".get_all_permission_from_group" do
    it "should return array of permissions" do
      user_group = UserGroup.find_by_id(1)
      user_group.permissions.class.should be Array
    end
  end
  
end
