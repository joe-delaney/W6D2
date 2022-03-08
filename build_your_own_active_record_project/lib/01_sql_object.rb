require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
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

  def self.all
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
    result = DBConnection.execute(<<-SQL, id)
    SELECT
      #{self.table_name}.*
    FROM
      #{self.table_name}
    WHERE
      id = (?)
    SQL
    result.first.nil? ? nil : self.new(result.first) 
  end

  def initialize(params = {})
    # debugger
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
    self.class.columns.map {|col| self.attributes[col] }
  end

  def insert
    col_names = self.class.columns.drop(1).join(',') #drop the id
    question_marks = (['?'] * (col_names.split(',').length)).join(',')
    DBConnection.execute(<<-SQL, *attribute_values.drop(1)) 
    INSERT INTO
      #{self.class.table_name} (#{col_names})
    VALUES
      (#{question_marks})
    SQL
    attributes[:id] = DBConnection.instance.last_insert_row_id
  end

  def update
    # debugger
    col_names = self.class.columns.drop(1) #drop the id
    set_line = col_names.map {|attr| "#{attr} = (?)"}.join(', ')
    id = attribute_values.shift
    DBConnection.execute(<<-SQL, *attribute_values.drop(1), id) 
    UPDATE
      #{self.class.table_name}
    SET
      #{set_line}
    WHERE
      id = (?)
    SQL
  end

  def save
    attributes[:id].nil? ? insert : update
  end

  private 
  def self.get_columns
    data = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      SQL
    data.first.map &:to_sym
  end
end
