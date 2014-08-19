class AddGroupPermissionNameToPermission < ActiveRecord::Migration
  def change
    add_column :permissions, :group_permission_name, :string
  end
end
