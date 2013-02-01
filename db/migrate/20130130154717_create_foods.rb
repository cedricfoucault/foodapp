# -*- encoding : utf-8 -*-
class CreateFoods < ActiveRecord::Migration
  def change
    create_table :foods do |t|
      # general info
      t.string :common_name
      t.string :manufacturer_name
      t.string :scientific_name
      t.string :category
      t.string :short_description
      t.string :long_description
      t.string :refuse_description
      t.float :refuse_percentage
      t.float :density
      # macronutrients
      t.float :energy
      t.float :water
      t.float :protein
      t.float :carbohydrate
      t.float :fat
      t.float :fibers
      t.float :sugar
      t.float :alcohol
      t.float :caffeine
      # fatty acids, fat micronutrients
      t.float :saturated_fat
      t.float :monounsaturated_fat
      t.float :polyunsaturated_fat
      t.float :trans_fat
      t.float :cholesterol
      t.float :omega_3
      t.float :epa
      t.float :dpa
      t.float :dha
      t.float :ala
      t.float :omega_6
      # minerals
      t.float :calcium
      t.float :iron
      t.float :magnesium
      t.float :phosphorus
      t.float :potassium
      t.float :sodium
      t.float :zinc
      t.float :copper
      t.float :manganese
      t.float :selenium
      t.float :fluoride
      # vitamins
      t.float :vit_a
      t.float :vit_b1
      t.float :vit_b2
      t.float :vit_b3
      t.float :vit_b5
      t.float :vit_b6
      t.float :vit_b7
      t.float :vit_b9
      t.float :vit_b12
      t.float :vit_c
      t.float :vit_d
      t.float :vit_e
      t.float :vit_k
      t.float :alpha_carotene
      t.float :beta_carotene
      # reference
      t.string :source
      t.timestamps
    end
  end
end

