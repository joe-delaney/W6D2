require_relative 'db_connection'
require_relative '01_sql_object'
require 'byebug'

module Searchable
  def where(params)
    where_line = params.map {|k, v| "#{k} = ?"}.join(' AND ')
    results = DBConnection.execute(<<-SQL, *params.values)
    SELECT
      *
    FROM
      #{self.table_name}
    WHERE
      #{where_line}
    SQL

    objects = []
    results.each do |result|
      objects << self.new(result)
    end
    objects
  end
end

class SQLObject extend Searchable
  # Mixin Searchable here...
  # include Searchable
end
