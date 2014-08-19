class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.text :description
      t.references :evidence

      t.timestamps
    end
    add_index :photos, :evidence_id
  end
end
