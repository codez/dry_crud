# encoding: UTF-8

module DryCrud::Form

  # Internal class to handle the rendering of a single form control,
  # consisting of a label, input field, addon, help text or
  # required mark.
  class Control

    attr_reader :builder, :attr, :args, :options, :span, :addon, :help

    delegate :content_tag, :object,
             to: :builder

    # Html displayed to mark an input as required.
    REQUIRED_MARK = '*'

    # Number of default input field span columns depending
    # on the #field_method.
    INPUT_SPANS = Hash.new(8)
    INPUT_SPANS[:number_field] =
      INPUT_SPANS[:integer_field] =
      INPUT_SPANS[:float_field]   =
      INPUT_SPANS[:decimal_field] = 2
    INPUT_SPANS[:date_field] =
      INPUT_SPANS[:time_field] = 3

    # Create a new control instance.
    # Takes the form builder, the attribute to build the control for
    # as well as any additional arguments for the field method.
    # This includes an options hash as the last argument, that
    # may contain the following special options:
    #
    # * <tt>:addon</tt> - Addon content displayd just after the input field.
    # * <tt>:help</tt> - A help text displayd below the input field.
    # * <tt>:span</tt> - Number of columns the input field should span.
    # * <tt>:caption</tt> - Different caption for the label.
    # * <tt>:field_method</tt> - Different method to create the input field.
    # * <tt>:required</tt> - Sets the field as required
    #   (The value for this option usually is 'required').
    #
    # All the other options will go to the field_method.
    def initialize(builder, attr, *args)
      @builder = builder
      @attr = attr
      @options = args.extract_options!
      @args = args

      @addon = options.delete(:addon)
      @help = options.delete(:help)
      @span = options.delete(:span)
      @caption = options.delete(:caption)
      @field_method = options.delete(:field_method)
      @required = options[:required]
    end

    # Renders only the content of the control.
    # I.e. no label and span divs.
    def render_content
      content
    end

    # Renders the complete control with label and everything.
    # Render the content given or the default one.
    def render_labeled(content = nil)
      @content = content if content
      labeled
    end

    private

    # Create the HTML markup for any labeled content.
    def labeled
      errors = errors? ? ' has-error' : ''

      content_tag(:div, class: "form-group#{errors}") do
        builder.label(attr, caption, class: 'col-md-2 control-label') +
        content_tag(:div, content, class: "col-md-#{span}")
      end
    end

    # Return the currently set content or create it
    # based on the various options given.
    #
    # Optionally renders addon, required mark and/or a help block
    # additionally to the input field.
    def content
      @content ||= begin
        content = input
        if addon
          content = builder.with_addon(content, addon)
        elsif required
          content = builder.with_addon(content, REQUIRED_MARK)
        end
        content << builder.help_block(help) if help.present?
        content
      end
    end

    # Return the currently set input field or create it
    # depending on the attribute.
    def input
      @input ||= begin
        builder.add_css_class(options, 'form-control')
        options[:required] = 'required' if required
        builder.send(field_method, attr, *(args << options))
      end
    end

    # The field method used to create the input.
    # If none is set, detect it from the attribute type.
    def field_method
      @field_method ||= detect_field_method
    end

    # True if the attr is required, false otherwise.
    def required
      @required = @required.nil? ? builder.required?(attr) : @required
    end

    # Number of grid columns the input field should span.
    def span
      @span ||= INPUT_SPANS[field_method]
    end

    # The caption of the label.
    # If none is set, uses the I18n value of the attribute.
    def caption
      @caption ||= builder.captionize(attr, object.class)
    end

    # Returns true if any errors are found on the passed attribute or its
    # association.
    def errors?
      attr_plain, attr_id = builder.assoc_and_id_attr(attr)
      # errors aint a Hash
      # rubocop:disable HashMethods
      object.errors.has_key?(attr_plain.to_sym) ||
      object.errors.has_key?(attr_id.to_sym)
      # rubocop:enable HashMethods
    end

    # Defines the field method to use based on the attribute
    # type, association or name.
    def detect_field_method
      if type == :text
        :text_area
      elsif association_kind?(:belongs_to)
        :belongs_to_field
      elsif association_kind?(:has_and_belongs_to_many, :has_many)
        :has_many_field
      elsif attr.to_s.include?('password')
        :password_field
      elsif attr.to_s.include?('email')
        :email_field
      elsif builder.respond_to?(:"#{type}_field")
        :"#{type}_field"
      else
        :text_field
      end
    end

    # The column type of the attribute.
    def type
      @type ||= builder.column_type(object, attr)
    end

    # Returns true if attr is a non-polymorphic association.
    # If one or more macros are given, the association must be of this kind.
    def association_kind?(*macros)
      if type == :integer || type.nil?
        assoc = builder.association(object, attr, *macros)

        assoc.present? && assoc.options[:polymorphic].nil?
      else
        false
      end
    end
  end
end
