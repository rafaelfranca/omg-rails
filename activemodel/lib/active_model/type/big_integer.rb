# frozen_string_literal: true

require "active_model/type/integer"

module ActiveModel
  module Type
    # Attribute type for integer representation with no byte range limit for
    # serialization. This type is registered under the +:big_integer+ key.
    #
    #   class Person
    #     include ActiveModel::Attributes
    #
    #     attribute :id, :big_integer
    #   end
    #
    #   person = Person.new(id: "18_000_000_000")
    #   person.id # => 18000000000
    #
    # All casting and serialization are performed in the same way as the
    # standard <tt>ActiveModel::Type::Integer</tt> type.
    class BigInteger < Integer
      private
        def max_value
          ::Float::INFINITY
        end
    end
  end
end
