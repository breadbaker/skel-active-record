require_relative './db_connection'

module Searchable
  # takes a hash like { :attr_name => :search_val1, :attr_name2 => :search_val2 }
  # map the keys of params to an array of  "#{key} = ?" to go in WHERE clause.
  # Hash#values will be helpful here.
  # returns an array of objects
  def where(params)
    clause = params.map do |k,v|
      "#{k}='#{v}'"
    end.join(' AND ')
    p clause
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
      #{clause}

    SQL

    return parse_all(results) unless results.empty?

    nil
  end
end