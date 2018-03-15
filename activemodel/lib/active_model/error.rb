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
      options = @options.dup

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
      value = (@attribute != :base ? @base.send(:read_attribute_for_validation, @attribute) : nil)
      if options[:message]
        defaults = options.delete(:message)
      end

      i18n_options = {
        default: defaults,
        model: @base.model_name.human,
        attribute: humanized_attribute,
        value: value,
        object: @base
      }.merge!(options)

      I18n.translate(key, i18n_options)
    end

    def full_message
      message = self.message

      return message if @attribute == :base

      I18n.t(:"errors.format",
        default: "%{attribute} %{message}",
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

    private

      def humanized_attribute
        return @_humanized_attribute if defined? @_humanized_attribute

        default = @attribute.to_s.tr(".", "_").humanize
        @_humanized_attribute = @base.class.human_attribute_name(@attribute, default: default)
      end
  end
end
