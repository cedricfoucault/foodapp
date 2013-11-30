# -*- encoding : utf-8 -*-
# require 'textacular/searchable'

class Food < ActiveRecord::Base
  include PgSearch
  
  attr_accessible *FOOD_FIELDS
  
  # there must be at least one name or description for the entry
  validate :at_least_one_name
  # any description / name must be unique
  validates :long_description, allow_nil: true, allow_blank: true,  uniqueness: true
  # validates :short_description, allow_nil: true, allow_blank: true, uniqueness: true
  # validates :common_name, allow_nil: true, allow_blank: true, uniqueness: true
  # validates :scientific_name, allow_nil: true, allow_blank: true, uniqueness: true
  pg_search_scope :search_fulltext,
                  :against => SEARCHABLE_FOOD_FIELDS,
                  :using => {
                    :tsearch => {
                      :prefix => true,
                      :dictionary => "english",
                      tsvector_column: 'textsearchable_col'
                    }
                  }
  
  def at_least_one_name
    if [self.common_name, self.manufacturer_name, self.scientific_name,
      self.long_description, self.short_description].compact.blank?
      errors[:base] << ("There must be at least one name or description for the entry.")
    end
  end
  
  # def self.search(name)
  #   pattern = name + "%" # entry must begin with the given string
  #   find(:all,
  #     conditions: ['LOWER(common_name) LIKE LOWER(?) OR LOWER(scientific_name) LIKE LOWER(?)'\
  #       ' OR LOWER(long_description) LIKE LOWER(?) OR LOWER(short_description) LIKE LOWER(?)',
  #       pattern, pattern, pattern, pattern],
  #     order: "length(long_description)")
  # end
  
  def self.search(text)
    # self.fuzzy_search(query)
    # results = self.search_fulltext(query).limit(20)
    # results.each {|r| puts r.pg_search_rank}
    # results
    # self.search_fulltext(query).limit(20).explain
    # self.search_fulltext(text).limit(16)
    n_results_limit = 16
    
    query_terms = self.query_terms_for_text(text)
    results = self.search_fulltext(text)
    logger.info query_terms
    
    rank = Hash.new { |rank, r|  rank[r] = self.rank_result(r, query_terms)}
    results.sort! {|r1, r2| rank[r1] <=> rank[r2]}
    results[0..(n_results_limit - 1)]
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
        # convert the value in the unit of measure used in the database
        if elem.has_attribute? 'unit'
          if field == :energy
            if is_energy_unit? elem['unit']
              val *= in_kcal(elem['unit'])
            else
              raise ArgumentError.new("Unknown unit of energy #{elem['unit']} for #{field}")
            end
          else
            if is_mass_unit? elem['unit']
              val *= in_g(elem['unit']) / in_g(UNIT_FOR[field])
            else
              raise ArgumentError.new("Unknown unit of mass #{elem['unit']} for #{field}")
            end
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
  
  DISALLOWED_TSQUERY_CHARACTERS = /['?\\:]/
  
  def self.rank_result(result, query_terms)
    # rank = [pos of first match for term 1, ..., pos of first match for term N, pg_search_rank]
    rank = query_terms.map do |term|
      min_pos = Float::INFINITY
      pos_regexp = Regexp.new("'#{term}\\w*':(\\d+)")
      # retrieve the min position of all matches if any
      result.textsearchable_col.scan(pos_regexp) do |match|
        if match[0].to_i < min_pos
          min_pos = match[0].to_i
        end
      end
      min_pos
    end
    rank << result.pg_search_rank
  end
  
  def self.query_terms_for_text(text)
    # retrieve the tsquery for the input text
    tsquery = self.tsquery_for_text(text)
    # parse the query to retrieve the individual terms
    terms = tsquery.split('&')
    terms.map! do |term|
      /'(\w*)':\*/.match(term.strip)[1]
    end
  end
  
  def self.tsquery_for_text(text)
    sanitized_term = text.gsub(DISALLOWED_TSQUERY_CHARACTERS, " ")

    term_sql = Arel.sql(connection.quote(sanitized_term))

    # After this, the SQL expression evaluates to a string containing the term surrounded by single-quotes.
    # If :prefix is true, then the term will also have :* appended to the end.
    terms = ["' ", term_sql, " '", ':*'].compact

    sql_query_term = terms.inject do |memo, term|
      Arel::Nodes::InfixOperation.new("||", memo, term)
    end
    sql_call_term = Arel::Nodes::NamedFunction.new(
      "to_tsquery",
      [:english, sql_query_term]
    ).to_sql
    sqlquery = "SELECT #{sql_call_term} AS query"
    ActiveRecord::Base.connection().execute(sqlquery).first['query']
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
  
  def self.is_mass_unit? unit
    [
      "g",
      "mg",
      "µg",
      "lb",
      "oz",
      "dr"
    ].include? unit
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
  
  def self.is_energy_unit? unit
    [
      "kcal",
      "kJ",
    ].include? unit
  end
  
  def self.in_kcal unit
    {
      "kcal" => 1,
      "kJ" => 0.2388458966275
    }[unit]
  end
  
  # extend Searchable(*SEARCHABLE_FOOD_FIELDS)
end

