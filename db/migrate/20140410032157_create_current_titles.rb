class CreateCurrentTitles < ActiveRecord::Migration
  def change
    create_table :current_titles do |t|
      t.integer :rank_id
      t.text :short_term
      t.text :long_term
      t.text :coach_plan
      t.references :user
      t.references :title

      t.timestamps
    end
    add_index :current_titles, :user_id
    add_index :current_titles, :title_id
  end
end
