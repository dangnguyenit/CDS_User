class CreateTitles < ActiveRecord::Migration
  def change
    create_table :titles do |t|
      t.string :name
      t.string :short_name
      t.integer :value
      t.references :title_group

      t.timestamps
    end
    add_index :titles, :title_group_id
  end
end
