##
# Add Projects Table
# @author DatPB
##
class CreateProjects < ActiveRecord::Migration
  def change
  	create_table :projects do |t|
      t.string :name
      t.text :description
      t.boolean :is_active, :default => true

      t.integer :organization_id

      t.timestamps
    end
  end
end

