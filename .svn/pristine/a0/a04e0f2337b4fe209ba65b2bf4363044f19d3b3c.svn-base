class AddOrgStructure < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.boolean :is_super_org, :default => false
      t.string :description
    end

    add_column :users, :organization_id, :integer
    add_column :user_groups, :organization_id, :integer
    add_column :activities, :organization_id, :integer

    add_index :users, :organization_id
    add_index :user_groups, :organization_id
    add_index :activities, :organization_id
  end
end
