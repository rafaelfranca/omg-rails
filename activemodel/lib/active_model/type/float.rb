# frozen_string_literal: true

require "active_support/core_ext/object/try"

module ActiveModel
  module Type
    # Attribute type for floating point numeric values. It is registered under
    # the +:float+ key.
    #
    #   class BagOfCoffee
    #     include ActiveModel::Attributes
    #
    #     attribute :weight, :float
    #   end
    #
    #   bag  = BagOfCoffee.new(weight: "0.25")
    #   bag.weight # => 0.25
    #
    # Values are coerced to their float representation using their +to_f+
    # methods. Certain strings might represent specific float constants, which
    # are cast accordingly:
    #
    # - <tt>"Infinity"</tt> is cast to <tt>Float::INFINITY</tt>.
    # - <tt>"-Infinity"</tt> is cast to <tt>-Float::INFINITY</tt>.
    # - <tt>"NaN"</tt> is cast to <tt>Float::NAN</tt>.
    #
    # Any other string value is cast into their +to_f+ representation.
    class Float < Value
      include Helpers::Numeric

      def type
        :float
      end

      def type_cast_for_schema(value)
        return "::Float::NAN" if value.try(:nan?)
        case value
        when ::Float::INFINITY then "::Float::INFINITY"
        when -::Float::INFINITY then "-::Float::INFINITY"
        else super
        end
      end

      private
        def cast_value(value)
          case value
          when ::Float then value
          when "Infinity" then ::Float::INFINITY
          when "-Infinity" then -::Float::INFINITY
          when "NaN" then ::Float::NAN
          else value.to_f
          end
        end
    end
  end
end
