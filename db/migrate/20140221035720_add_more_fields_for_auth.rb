##
# Add more field to some table for Authentication/Permission Feature
# @author DatPB
##
class AddMoreFieldsForAuth < ActiveRecord::Migration
  def up
    #For groups PM, TL: user must be in a Project of this Organization
    #Other Groups: not need => this field will be nil
    add_column :user_groups_users, :project_id, :integer

  end

  def down
    remove_column :user_groups_users, :project_id
  end
end
