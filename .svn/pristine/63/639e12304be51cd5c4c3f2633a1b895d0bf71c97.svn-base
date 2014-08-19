class AddTables < ActiveRecord::Migration
  def change
    create_table :user_groups do |t|
      t.string :name
      t.text :description
      t.boolean :is_active, :default => true

      t.timestamps
    end

    create_table :user_groups_users do |t|
      t.integer :user_group_id
      t.integer :user_id

      t.timestamps
    end

    add_column :users, :is_admin, :boolean, :default => false
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :is_deleted, :boolean, :default => false

    create_table :permissions do |t|
      t.string :name
      t.string :code

      t.timestamps
    end

    create_table :user_groups_permissions do |t|
      t.integer :user_group_id
      t.integer :permission_id

      t.timestamps
    end

  end

end
