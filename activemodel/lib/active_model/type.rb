# frozen_string_literal: true

require "active_model/type/helpers"
require "active_model/type/value"

require "active_model/type/big_integer"
require "active_model/type/binary"
require "active_model/type/boolean"
require "active_model/type/date"
require "active_model/type/date_time"
require "active_model/type/decimal"
require "active_model/type/float"
require "active_model/type/immutable_string"
require "active_model/type/integer"
require "active_model/type/string"
require "active_model/type/time"

require "active_model/type/registry"

module ActiveModel
  # The Type module works as the namespace for all type classes as well as
  # exposes the public interface to register and lookup types. At load time it
  # instantiates a global type Registry and sets all standard types on it.
  module Type
    @registry = Registry.new

    class << self
      attr_accessor :registry # :nodoc:

      # Add a new type to the registry, allowing it to be referenced as a
      # symbol by {attribute}[rdoc-ref:Attributes::ClassMethods#attribute].
      def register(type_name, klass = nil, &block)
        registry.register(type_name, klass, &block)
      end

      # Type lookup, delegated to the global Registry instance.
      def lookup(...) # :nodoc:
        registry.lookup(...)
      end

      # Memoizes (globally) and returns an instance of Value, the default type
      # class, which is used as the default type when a type is not set during
      # an attribute declaration.
      def default_value # :nodoc:
        @default_value ||= Value.new
      end
    end

    register(:big_integer, Type::BigInteger)
    register(:binary, Type::Binary)
    register(:boolean, Type::Boolean)
    register(:date, Type::Date)
    register(:datetime, Type::DateTime)
    register(:decimal, Type::Decimal)
    register(:float, Type::Float)
    register(:immutable_string, Type::ImmutableString)
    register(:integer, Type::Integer)
    register(:string, Type::String)
    register(:time, Type::Time)
  end
end
