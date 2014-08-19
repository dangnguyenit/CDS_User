class CreateTitleGroups < ActiveRecord::Migration
  def change
    create_table :title_groups do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
