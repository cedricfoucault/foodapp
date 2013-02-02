# -*- encoding : utf-8 -*-
class Food < ActiveRecord::Base
  attr_accessible *FOOD_FIELDS
  
  # there must be at least one name or description for the entry
  validate :at_least_one_name
  # any description / name must be unique
  validates :long_description, allow_nil: true, allow_blank: true,  uniqueness: true
  # validates :short_description, allow_nil: true, allow_blank: true, uniqueness: true
  # validates :common_name, allow_nil: true, allow_blank: true, uniqueness: true
  # validates :scientific_name, allow_nil: true, allow_blank: true, uniqueness: true
  
  def at_least_one_name
    if [self.common_name, self.manufacturer_name, self.scientific_name,
      self.long_description, self.short_description].compact.blank?
      errors[:base] << ("There must be at least one name or description for the entry.")
    end
  end
  

  def self.xmlfood_to_hash xmlstring
    begin
      # parse the given XML string
      doc = Nokogiri::XML(xmlstring) { |config| config.strict.noblanks }
      if doc.root.name.downcase != 'food'
        raise ArgumentError.new("Improper XML food document (root =/= food)")
      end
      
      food = {} # the food hash parsed from the XML document
      doc.xpath("/food/*").each do |elem|
        # retrieve the table field from the element name
        field = elem.name.downcase.to_sym
        # check that this field is a valid food field
        if not FOOD_FIELDS.include? field
          raise ArgumentError.new("Improper XML food document (unknown field #{field})")
        end
        # retrieve the value to put in the database for this field
        val = is_numeric?(field) ? elem.text.to_f : elem.text
        if elem.has_attribute? 'unit'
          # puts elem['unit']
          # puts field
          # convert the value in the unit of measure used in the database
          if field == :energy
            val *= in_kcal(elem['unit'])
          else
            val *= in_g(elem['unit']) / in_g(UNIT_FOR[field])
          end
        end
        # add it in the hash
        food[field] = val
      end
      
      return food
    rescue Nokogiri::XML::SyntaxError => e
      raise ArgumentError.new("Improper XML syntax: #{e}")
    end
  end
  
  def self.is_numeric? field
    not is_text? field
  end
  
  def self.is_text? field
    [
      :category,
      :common_name,
      :manufacturer_name,
      :scientific_name,
      :long_description,
      :short_description,
      :refuse_description,
      :source,
    ].include? field
  end
  
  def self.in_g unit
    {
      "g" => 1,
      "mg" => 1e-3,
      "µg" => 1e-6,
      "lb" => 453.59237,
      "oz" => 28.349523,
      "dr" => 1.771845
    }[unit]
  end
  
  def self.in_kcal unit
    {
      "kcal" => 1,
      "kJ" => 0.2388458966275
    }[unit]
  end

end

