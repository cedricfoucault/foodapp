class AddTextSearchableColTrigger < ActiveRecord::Migration
  def up
    execute %q!CREATE TRIGGER textsearchable_col_update BEFORE INSERT OR UPDATE ON foods FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger(textsearchable_col, 'english', common_name, short_description, long_description, scientific_name);!
  end

  def down
    execute %q!DROP TRIGGER textsearchable_col_update ON foods;!
  end
end
