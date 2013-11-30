class SetTextSearchableCol < ActiveRecord::Migration
  def up
    execute %q!UPDATE foods SET textsearchable_col = (to_tsvector('english', coalesce("foods"."common_name"::text, '')) || to_tsvector('english', coalesce("foods"."short_description"::text, '')) || to_tsvector('english', coalesce("foods"."long_description"::text, '')) || to_tsvector('english', coalesce("foods"."scientific_name"::text, '')));!
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

