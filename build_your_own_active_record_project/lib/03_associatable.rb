require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    # ...
  end

  def table_name
    # ...
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    # debugger
    if options.has_key?(:primary_key)
        @primary_key = options[:primary_key]
    else
        @primary_key = :id
    end

    if options.has_key?(:foreign_key)
        @foreign_key = options[:foreign_key]
    else
        @foreign_key = "#{name.underscore}_id".to_sym
    end

    if options.has_key?(:class_name)
        @class_name = options[:class_name]
    else
        @class_name = "#{name.camelcase.singularize}"
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    if options.has_key?(:primary_key)
        @primary_key = options[:primary_key]
    else
        @primary_key = :id
    end

    if options.has_key?(:foreign_key)
        @foreign_key = options[:foreign_key]
    else
        @foreign_key = "#{name.underscore}_id".to_sym
    end

    if options.has_key?(:class_name)
        @class_name = options[:class_name]
    else
        @class_name = "#{name.camelcase.singularize}"
    end
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    # ...
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject extend Associatable
  # Mixin Associatable here...
end
