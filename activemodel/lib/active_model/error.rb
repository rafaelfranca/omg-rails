# frozen_string_literal: true

module ActiveModel
  # == Active \Model \Error
  #
  # Represents one single error
  class Error
    def initialize(base, attribute, type = nil, **options)
      @base = base
      @attribute = attribute
      @type = type || :invalid
      @options = options
    end

    def initialize_dup(other)
      @attribute = @attribute.dup
      @type = @type.dup
      @options = @options.deep_dup
    end

    attr_reader :base, :attribute, :type, :options

    # Translates an error message in its default scope
    # (<tt>activemodel.errors.messages</tt>).
    #
    # Error messages are first looked up in <tt>activemodel.errors.models.MODEL.attributes.ATTRIBUTE.MESSAGE</tt>,
    # if it's not there, it's looked up in <tt>activemodel.errors.models.MODEL.MESSAGE</tt> and if
    # that is not there also, it returns the translation of the default message
    # (e.g. <tt>activemodel.errors.messages.MESSAGE</tt>). The translated model
    # name, translated attribute name and the value are available for
    # interpolation.
    #
    # When using inheritance in your models, it will check all the inherited
    # models too, but only if the model itself hasn't been found. Say you have
    # <tt>class Admin < User; end</tt> and you wanted the translation for
    # the <tt>:blank</tt> error message for the <tt>title</tt> attribute,
    # it looks for these translations:
    #
    # * <tt>activemodel.errors.models.admin.attributes.title.blank</tt>
    # * <tt>activemodel.errors.models.admin.blank</tt>
    # * <tt>activemodel.errors.models.user.attributes.title.blank</tt>
    # * <tt>activemodel.errors.models.user.blank</tt>
    # * any default you provided through the +options+ hash (in the <tt>activemodel.errors</tt> scope)
    # * <tt>activemodel.errors.messages.blank</tt>
    # * <tt>errors.attributes.title.blank</tt>
    # * <tt>errors.messages.blank</tt>
    def message
      type = @type
      if msg = @options[:message]
        if msg.is_a?(Symbol)
          # TODO: Having options[:message] to act as an alternative i18n lookup key seems to be wrong.
          # We should have a separate new key for this, for example `:lookup_key`,
          # this way lookup_key can also be a Proc and generated dynamically.
          type = msg
          msg = nil
        end
        options = @options.except(:message)
      else
        options = @options
      end

      if @base.class.respond_to?(:i18n_scope)
        i18n_scope = @base.class.i18n_scope.to_s
        defaults = @base.class.lookup_ancestors.flat_map do |klass|
          [ :"#{i18n_scope}.errors.models.#{klass.model_name.i18n_key}.attributes.#{@attribute}.#{type}",
            :"#{i18n_scope}.errors.models.#{klass.model_name.i18n_key}.#{type}" ]
        end
        defaults << :"#{i18n_scope}.errors.messages.#{type}"
      else
        defaults = []
      end

      defaults << :"errors.attributes.#{@attribute}.#{type}"
      defaults << :"errors.messages.#{type}"

      key = defaults.shift
      begin
        value = (@attribute != :base ? @base.send(:read_attribute_for_validation, @attribute) : nil)
      rescue NoMethodError
        ActiveSupport::Deprecation.warn("\"#{msg}\" error was added to `#{@attribute}` attribute, but that attribute does not exist. This behavior will be deprecated and raise exception in Rails 6.1")
        return msg
      end

      i18n_options = {
        default: msg || defaults,
        model: @base.model_name.human,
        attribute: humanized_attribute,
        value: value,
        object: @base
      }.merge!(options)

      I18n.translate(key, i18n_options)
    end

    # Returns a full message for a given attribute.
    #
    #   person.errors.first.full_message # => "Name is invalid"
    #
    #   The `"%{attribute} %{message}"` error format can be overridden with either
    #
    # * <tt>activemodel.errors.models.person/contacts/addresses.attributes.street.format</tt>
    # * <tt>activemodel.errors.models.person/contacts/addresses.format</tt>
    # * <tt>activemodel.errors.models.person.attributes.name.format</tt>
    # * <tt>activemodel.errors.models.person.format</tt>
    # * <tt>errors.format</tt>
    def full_message
      message = self.message

      return message if @attribute == :base

      if ActiveModel::Errors.i18n_full_message && @base.class.respond_to?(:i18n_scope)
        parts = attribute_without_index.split(".")
        attribute_name = parts.pop
        namespace = parts.join("/") unless parts.empty?
        attributes_scope = "#{@base.class.i18n_scope}.errors.models"

        if namespace
          defaults = @base.class.lookup_ancestors.map do |klass|
            [
              :"#{attributes_scope}.#{klass.model_name.i18n_key}/#{namespace}.attributes.#{attribute_name}.format",
              :"#{attributes_scope}.#{klass.model_name.i18n_key}/#{namespace}.format",
            ]
          end
        else
          defaults = @base.class.lookup_ancestors.map do |klass|
            [
              :"#{attributes_scope}.#{klass.model_name.i18n_key}.attributes.#{attribute_name}.format",
              :"#{attributes_scope}.#{klass.model_name.i18n_key}.format",
            ]
          end
        end

        defaults.flatten!
      else
        defaults = []
      end

      defaults << :"errors.format"
      defaults << "%{attribute} %{message}"

      I18n.t(defaults.shift,
        default: defaults,
        attribute: humanized_attribute,
        message: message)
    end

    # See if error matches provided +attribute+, +type+ and +options+.
    def match?(attribute, type = nil, **options)
      if @attribute != attribute || (type && @type != type)
        return false
      end

      options.each do |key, value|
        if @options[key] != value
          return false
        end
      end

      true
    end

    def strict_match?(attribute, type, **options)
      return false unless match?(attribute, type, **options)

      full_message == Error.new(@base, attribute, type, **options).full_message
    end

    def ==(other)
      other.is_a?(self.class) && attributes_for_hash == other.attributes_for_hash
    end
    alias eql? ==

    def hash
      attributes_for_hash.hash
    end

    protected

      def attributes_for_hash
        [@base, @attribute, @type, @options]
      end

    private

      def humanized_attribute
        return @_humanized_attribute if defined? @_humanized_attribute

        default = attribute_without_index.tr(".", "_").humanize

        @_humanized_attribute = @base.class.human_attribute_name(attribute, default: default)
      end

      def attribute_without_index
        @_attribute_without_index ||= attribute.to_s.remove(/\[\d\]/)
      end
  end
end
