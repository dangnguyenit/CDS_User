class CreateShortTermObjectives < ActiveRecord::Migration
  def change
    create_table :short_term_objectives do |t|
      t.string :title
      t.text :short_term
      t.text :action_plan
      t.datetime :target_date
      t.references :current_title

      t.timestamps
    end
    add_index :short_term_objectives, :current_title_id
  end
end
