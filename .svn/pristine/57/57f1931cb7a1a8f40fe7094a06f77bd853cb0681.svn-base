class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :obj_user_id
      t.integer :obj_id
      t.string :obj_type
      t.string :notification_type
      t.boolean :is_seen
      t.references :user

      t.timestamps
    end
    add_index :notifications, :user_id
  end
end
