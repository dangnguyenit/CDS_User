class CreateSlotAssesses < ActiveRecord::Migration
  def change
    create_table :slot_assesses do |t|
      t.string :value
      t.string :self_value
      t.string :status
      t.boolean :is_notified
      t.integer :approved_user_id
      t.string :competency_name
      t.string :level_name
      t.string :slot_name
      t.references :slot
      t.references :user

      t.timestamps
    end
    add_index :slot_assesses, :slot_id
    add_index :slot_assesses, :user_id
  end
end
