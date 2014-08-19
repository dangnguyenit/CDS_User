class AddStatusToDepartments < ActiveRecord::Migration
  def change
    add_column :departments, :status, :boolean
  end
end
