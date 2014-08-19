class AddCareerPathToTitles < ActiveRecord::Migration
  def change
    add_column :titles, :career_path, :string
  end
end
