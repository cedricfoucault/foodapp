class AddTextSearchableColToFoods < ActiveRecord::Migration
  def change
    add_column :foods, :textsearchable_col, :tsvector
  end
end
