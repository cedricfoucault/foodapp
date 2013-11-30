class AddFoodsSearchIndex < ActiveRecord::Migration
  def up
    execute %q!CREATE INDEX textsearch_idx ON foods USING gin(textsearchable_col)!
  end

  def down
    execute "DROP INDEX textsearch_idx"
  end
end
