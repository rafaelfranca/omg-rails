# frozen_string_literal: true

module ActiveModel
  module Type
    # Attribute type to represent immutable strings. It casts incoming values to
    # frozen strings.
    #
    #   class Person
    #     include ActiveModel::Attributes
    #
    #     attribute :name, :immutable_string
    #   end
    #
    #   person = Person.new
    #   person.name = 1
    #   person.name # => "1"
    #   person.name.frozen? # => true
    #
    # Values are coerced based on their +to_s+ method. Boolean values are
    # treated differently, however: it will cast +true+ to <tt>"t"</tt> and
    # +false+ to <tt>"f"</tt> strings. These values can be customized during the
    # attribute definition:
    #
    #   class Person
    #     include ActiveModel::Attributes
    #
    #     attribute :active, :immutable_string, true: "aye", false: "nay"
    #   end
    #
    #   person = Person.new(active: true)
    #   person.active # => "aye"
    class ImmutableString < Value
      def initialize(**args)
        @true  = -(args.delete(:true)&.to_s  || "t")
        @false = -(args.delete(:false)&.to_s || "f")
        super
      end

      def type
        :string
      end

      def serialize(value)
        case value
        when ::Numeric, ::Symbol, ActiveSupport::Duration then value.to_s
        when true then @true
        when false then @false
        else super
        end
      end

      private
        def cast_value(value)
          case value
          when true then @true
          when false then @false
          else value.to_s.freeze
          end
        end
    end
  end
end
