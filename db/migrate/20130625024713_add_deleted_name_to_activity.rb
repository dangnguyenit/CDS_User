class AddDeletedNameToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :deleted_name, :string
  end
end
