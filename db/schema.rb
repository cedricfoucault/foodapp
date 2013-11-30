# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130624064343) do

  create_table "foods", :force => true do |t|
    t.string   "common_name"
    t.string   "manufacturer_name"
    t.string   "scientific_name"
    t.string   "category"
    t.string   "short_description"
    t.string   "long_description"
    t.string   "refuse_description"
    t.float    "refuse_percentage"
    t.float    "density"
    t.float    "energy"
    t.float    "water"
    t.float    "protein"
    t.float    "carbohydrate"
    t.float    "fat"
    t.float    "fibers"
    t.float    "sugar"
    t.float    "alcohol"
    t.float    "caffeine"
    t.float    "saturated_fat"
    t.float    "monounsaturated_fat"
    t.float    "polyunsaturated_fat"
    t.float    "trans_fat"
    t.float    "cholesterol"
    t.float    "omega_3"
    t.float    "epa"
    t.float    "dpa"
    t.float    "dha"
    t.float    "ala"
    t.float    "omega_6"
    t.float    "calcium"
    t.float    "iron"
    t.float    "magnesium"
    t.float    "phosphorus"
    t.float    "potassium"
    t.float    "sodium"
    t.float    "zinc"
    t.float    "copper"
    t.float    "manganese"
    t.float    "selenium"
    t.float    "fluoride"
    t.float    "vit_a"
    t.float    "vit_b1"
    t.float    "vit_b2"
    t.float    "vit_b3"
    t.float    "vit_b5"
    t.float    "vit_b6"
    t.float    "vit_b7"
    t.float    "vit_b9"
    t.float    "vit_b12"
    t.float    "vit_c"
    t.float    "vit_d"
    t.float    "vit_e"
    t.float    "vit_k"
    t.float    "alpha_carotene"
    t.float    "beta_carotene"
    t.string   "source"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.tsvector "textsearchable_col"
  end

  add_index "foods", ["textsearchable_col"], :name => "textsearch_idx"

end
