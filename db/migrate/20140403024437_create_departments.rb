class CreateDepartments < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.string :name
      t.text :description
      t.integer :manager_id
      t.references :cds_template

      t.timestamps
    end
    add_index :departments, :cds_template_id
  end
end
