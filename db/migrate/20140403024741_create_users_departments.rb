class CreateUsersDepartments < ActiveRecord::Migration
  def change
    create_table :users_departments do |t|
    	t.boolean :is_actived
      t.belongs_to :user
      t.belongs_to :department

      t.timestamps
    end
    add_index :users_departments, :user_id
    add_index :users_departments, :department_id
  end
end
