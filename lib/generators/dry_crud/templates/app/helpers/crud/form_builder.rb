# encoding: UTF-8

module Crud
  # A form builder that automatically selects the corresponding input field
  # for ActiveRecord column types. Convenience methods for each column type
  # allow one to customize the different fields.
  #
  # All field methods may be prefixed with +labeled_+ in order to render
  # a standard label, required mark and an optional help block with them.
  #
  # Use #labeled_input_field or #input_field to render a input field
  # corresponding to the given attribute.
  #
  # See the Control class below to customize the html rendered for a
  # single input field.
  class FormBuilder < ActionView::Helpers::FormBuilder

    attr_reader :template

    delegate :association, :column_type, :column_property, :captionize,
             :ti, :ta, :link_to, :content_tag, :safe_join, :capture,
             :add_css_class, :assoc_and_id_attr,
             to: :template

    ### INPUT FIELDS

    # Render multiple input controls together with a label for the given
    # attributes.
    def labeled_input_fields(*attrs)
      options = attrs.extract_options!
      safe_join(attrs) { |a| labeled_input_field(a, options.dup) }
    end

    # Render a corresponding input control and label for the given attribute.
    # The input field is chosen based on the ActiveRecord column type.
    #
    # The following options may be passed:
    # * <tt>:addon</tt> - Addon content displayd just after the input field.
    # * <tt>:help</tt> - A help text displayd below the input field.
    # * <tt>:span</tt> - Number of columns the input field should span.
    # * <tt>:caption</tt> - Different caption for the label.
    # * <tt>:field_method</tt> - Different method to create the input field.
    #
    # Use additional html_options for the input element.
    def labeled_input_field(attr, html_options = {})
      Control.new(self, attr, html_options).render_labeled
    end

    # Render a corresponding input control for the given attribute.
    # The input field is chosen based on the ActiveRecord column type.
    #
    # The following options may be passed:
    # * <tt>:addon</tt> - Addon content displayd just after the input field.
    # * <tt>:help</tt> - A help text displayd below the input field.
    # * <tt>:span</tt> - Number of columns the input field should span.
    # * <tt>:field_method</tt> - Different method to create the input field.
    #
    # Use additional html_options for the input element.
    def input_field(attr, html_options = {})
      Control.new(self, attr, html_options).render_content
    end

    # Render a standard string field with column contraints.
    def string_field(attr, html_options = {})
      html_options[:maxlength] ||= column_property(@object, attr, :limit)
      text_field(attr, html_options)
    end

    # Render a boolean field.
    def boolean_field(attr, html_options = {})
      add_css_class(html_options, 'form-control')
      check_box(attr, html_options)
    end

    # Customize the standard text area to have 5 rows by default.
    def text_area(attr, html_options = {})
      html_options[:rows] ||= 5
      super
    end

    alias_method :integer_field, :number_field
    alias_method :float_field, :number_field
    alias_method :decimal_field, :number_field

    # Render a select element for a :belongs_to association defined by attr.
    # Use additional html_options for the select element.
    # To pass a custom element list, specify the list with the :list key or
    # define an instance variable with the pluralized name of the association.
    def belongs_to_field(attr, html_options = {})
      list = association_entries(attr, html_options).to_a
      if list.present?
        collection_select(attr, list, :id, :to_s,
                          select_options(attr, html_options),
                          html_options)
      else
        static_text(ta(:none_available, association(@object, attr)).html_safe)
      end
    end

    # Render a multi select element for a :has_many or :has_and_belongs_to_many
    # association defined by attr.
    # Use additional html_options for the select element.
    # To pass a custom element list, specify the list with the :list key or
    # define an instance variable with the pluralized name of the association.
    def has_many_field(attr, html_options = {})
      html_options[:multiple] = true
      add_css_class(html_options, 'multiselect')
      belongs_to_field(attr, html_options)
    end

    ### VARIOUS FORM ELEMENTS

    # Render the error messages for the current form.
    def error_messages
      @template.render('shared/error_messages',
                       errors: @object.errors,
                       object: @object)
    end

    # Renders the given content with an addon.
    def with_addon(content, addon)
      content_tag(:div, class: 'input-group') do
        content + content_tag(:span, addon, class: 'input-group-addon')
      end
    end

    # Renders a static text where otherwise form inputs appear.
    def static_text(text)
      content_tag(:p, text, class: 'form-control-static')
    end

    # Generates a help block for fields
    def help_block(text)
      content_tag(:p, text, class: 'help-block')
    end

    # Render a submit button and a cancel link for this form.
    def standard_actions(submit_label = ti('button.save'), cancel_url = nil)
      content_tag(:div, class: 'col-md-offset-2 col-md-8') do
        safe_join([submit_button(submit_label), cancel_link(cancel_url)], ' ')
      end
    end

    # Render a standard submit button with the given label.
    def submit_button(label = ti('button.save'))
      button(label, class: 'btn btn-primary', data: { disable_with: label })
    end

    # Render a cancel link pointing to the given url.
    def cancel_link(url = nil)
      url ||= cancel_url
      link_to(ti('button.cancel'), url, class: 'cancel')
    end

    # Depending if the given attribute must be present, return
    # only an initial selection prompt or a blank option, respectively.
    def select_options(attr, options = {})
      prompt = options.delete(:prompt)
      blank = options.delete(:include_blank)
      if options[:multiple]
        {}
      elsif prompt
        { prompt: prompt }
      elsif blank
        { include_blank: blank }
      else
        assoc = association(@object, attr)
        if required?(attr)
          { prompt: ta(:please_select, assoc) }
        else
          { include_blank: ta(:no_entry, assoc) }
        end
      end
    end

    # Returns true if the given attribute must be present.
    def required?(attr)
      attr, attr_id = assoc_and_id_attr(attr)
      validators = @object.class.validators_on(attr) +
                   @object.class.validators_on(attr_id)
      validators.any? do |v|
        v.kind == :presence &&
        !v.options.key?(:if) &&
        !v.options.key?(:unless)
      end
    end

    # Render a label for the given attribute with the passed field html
    # section. The following parameters may be specified:
    #   labeled(:attr) { #content }
    #   labeled(:attr, content)
    #   labeled(:attr, 'Caption') { #content }
    #   labeled(:attr, 'Caption', content)
    def labeled(attr, caption_or_content = nil, content = nil, &block)
      caption, content = extract_caption_and_content(
                           attr, caption_or_content, content, &block)

      control = Control.new(self, attr, caption: caption)
      control.render_labeled(content)
    end

    # Dispatch methods starting with 'labeled_' to render a label and the
    # corresponding input field.
    # E.g. labeled_boolean_field(:checked, class: 'bold')
    # To add an additional help text, use the help option.
    # E.g. labeled_boolean_field(:checked, help: 'Some Help')
    def method_missing(name, *args)
      field_method = labeled_field_method?(name)
      if field_method
        build_labeled_field(field_method, *args)
      else
        super(name, *args)
      end
    end

    # Overriden to fullfill contract with method_missing 'labeled_' methods.
    def respond_to?(name)
      labeled_field_method?(name).present? || super(name)
    end

    private

    # Checks if the passed name corresponds to a field method with a
    # 'labeled_' prefix.
    def labeled_field_method?(name)
      prefix = 'labeled_'
      if name.to_s.start_with?(prefix)
        field_method = name.to_s[prefix.size..-1]
        field_method if respond_to?(field_method)
      end
    end

    # Renders the corresponding field together with a label, required mark and
    # an optional help block.
    def build_labeled_field(field_method, *args)
      options = args.extract_options!
      options[:field_method] = field_method
      Control.new(self, *(args << options)).render_labeled
    end

    # Get caption and content value from the arguments of #labeled.
    def extract_caption_and_content(attr, caption_or_content, content, &block)
      if block_given?
        content = capture(&block)
      elsif content.nil?
        content = caption_or_content
        caption_or_content = nil
      end
      caption_or_content ||= captionize(attr, @object.class)

      [caption_or_content, content]
    end

    # Returns the list of association entries, either from options[:list],
    # the instance variable with the pluralized association name or all
    # entries of the association klass.
    def association_entries(attr, options)
      list = options.delete(:list)
      unless list
        assoc = association(@object, attr)
        list = @template.send(:instance_variable_get,
                              :"@#{assoc.name.to_s.pluralize}")
        unless list
          list = assoc.klass.where(assoc.options[:conditions])
                            .order(assoc.options[:order])
        end
      end
      list
    end

    # Get the cancel url for the given object considering options:
    # 1. Use :cancel_url_new or :cancel_url_edit option, if present
    # 2. Use :cancel_url option, if present
    def cancel_url
      url = @object.new_record? ? options[:cancel_url_new] :
                                  options[:cancel_url_edit]
      url || options[:cancel_url]
    end

    # Internal class to handle the rendering of a single control,
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
        object.errors.has_key?(attr_plain.to_sym) ||
        object.errors.has_key?(attr_id.to_sym)
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
end