class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :comment
      t.text :comment_type
      t.references :user
      t.references :evidence
      t.references :current_title
      t.references :short_term_objective

      t.timestamps
    end
    add_index :comments, :user_id
    add_index :comments, :evidence_id
    add_index :comments, :current_title_id
    add_index :comments, :short_term_objective_id
  end
end
