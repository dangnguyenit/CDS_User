##
# Add Projects Users Table: Store relationship between User & Project
# @author DatPB
##
class CreateProjectsUsers < ActiveRecord::Migration
  def change
  	create_table :projects_users do |t|
      t.integer :user_id
      t.integer :project_id

      t.timestamps
    end
  end
end