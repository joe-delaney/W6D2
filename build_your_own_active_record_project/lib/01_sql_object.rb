require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    @columns ||= get_columns
    @columns
  end

  def self.finalize!
    columns.each do |column_name|
      #getter
      define_method(column_name) { attributes[column_name]}

      #setter
      define_method("#{column_name}=") do |set_value|
        attributes[column_name] = set_value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.name.tableize
    @table_name
  end

  require "byebug"
  def self.all
    # debugger
    tb_name = table_name
    hashes = DBConnection.execute(<<-SQL)
    SELECT
      #{self.table_name}.*
    FROM
      #{self.table_name}
    SQL
    parse_all(hashes)
  end

  def self.parse_all(results)
    results.map {|result| self.new(result)}
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
    params.each do |key, val|
      if self.class.columns.include?(key.to_sym)
        send("#{key}=", val)
      else
        raise "unknown attribute \'#{key}\'"
      end
    end
  end

  def attributes
    @attributes ||= {}
    @attributes
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end

  private 
  def self.get_columns
    data = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        cats
      SQL
    data.first.map &:to_sym
  end
end
