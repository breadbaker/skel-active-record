require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  def other_class
  end

  def other_table
  end
end

class BelongsToAssocParams < AssocParams
  def initialize(name, params)
  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  def initialize(name, params, self_class)
  end

  def type
  end
end

module Associatable
  def assoc_params
  end

  def belongs_to(name, params = {})
    self.send(:define_method,name) do |v|
      #self.class.where(:p => "Breakfast")[0]
      # clause = params.map do |k,v|
#         "#{k}='#{v}'"
#       end.join(' AND ')
#       p clause
      results = DBConnection.execute(<<-SQL)
        SELECT
          humans.*
        FROM
          cats
          JOIN
          humans
          on
          human.id = cats.human_id
        WHERE
        id = #{self.class.id}


      SQL

      return parse_all(results).first unless results.empty?

      nil
    end
    # :human
#     :class_name => "Human", :primary_key => :id, :foreign_key => :owner_id

  end

  def has_many(name, params = {})
  end

  def has_one_through(name, assoc1, assoc2)
  end
end
