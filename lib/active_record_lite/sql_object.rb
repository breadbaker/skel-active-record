require_relative './associatable'
require_relative './db_connection' # use DBConnection.execute freely here.
require_relative './mass_object'
require_relative './searchable'

class SQLObject < MassObject
  extend Searchable
  extend Associatable
  # sets the table_name
  def self.set_table_name(table_name)
    @table_name = table_name
  end

  # gets the table_name
  def self.table_name
    @table_name
  end

  # querys database for all records for this type. (result is array of hashes)
  # converts resulting array of hashes to an array of objects by calling ::new
  # for each row in the result. (might want to call #to_sym on keys)
  def self.all
    parse_all DBConnection.execute(<<-SQL)
          SELECT *
            FROM #{table_name}
        SQL
  end

  # querys database for record of this type with id passed.
  # returns either a single object or nil.
  def self.find(id)
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = #{id}
    SQL

    return parse_all(results).first unless results.empty?

    nil
  end

  # executes query that creates record in db with objects attribute values.
  # use send and map to get instance values.
  # after, update the id attribute with the helper method from db_connection
  def create
    attrs = self.class.attributes.join(",")
    vars = attrs.map {|x| "?"}.join(',')

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{attrs})
      VALUES
        (#{vars})
    SQL

    @id = DBConnection.last_insert_row_id
  end

  # executes query that updates the row in the db corresponding to this instance
  # of the class. use "#{attr_name} = ?" and join with ', ' for set string.
  def update
    attr_vals = attribute_values
    up = self.class.attributes.map.with_index do |k, i|
      "#{k}='#{attr_vals[i]}'"
    end.join(',')
    DBConnection.execute(<<-SQL)
    UPDATE
      #{self.class.table_name}
    SET
      #{up}
    WHERE
      id=#{id};
    SQL
  end

  # call either create or update depending if id is nil.
  def save
    id.nil? ? create : update
  end

  # helper method to return values of the attributes.
  def attribute_values
    self.class.attributes.map {|x| self.send(x)}
  end
end
