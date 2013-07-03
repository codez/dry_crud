# encoding: UTF-8

module Crud
  # A form builder that automatically selects the corresponding input field
  # for ActiveRecord column types. Convenience methods for each column type
  # allow one to customize the different fields.
  # All field methods may be prefixed with 'labeled_' in order to render
  # a standard label with them.
  class FormBuilder < ActionView::Helpers::FormBuilder

    REQUIRED_MARK = '<span class="required">*</span>'.html_safe

    attr_reader :template

    delegate :association, :column_type, :column_property, :captionize,
             :ti, :ta, :link_to, :content_tag, :safe_join, :capture,
             :add_css_class, :assoc_and_id_attr,
             :to => :template

    ### INPUT FIELDS

    # Render multiple input fields together with a label for the given
    # attributes.
    def labeled_input_fields(*attrs)
      options = attrs.extract_options!
      safe_join(attrs) { |a| labeled_input_field(a, options.clone) }
    end

    # Render a corresponding input field for the given attribute.
    # The input field is chosen based on the ActiveRecord column type.
    # Use additional html_options for the input element.
    def input_field(attr, html_options = {})
      type = column_type(@object, attr)
      custom_field_method = :"#{type}_field"
      if type == :text
        text_area(attr, html_options)
      elsif association_kind?(attr, type, :belongs_to)
        belongs_to_field(attr, html_options)
      elsif association_kind?(attr, type, :has_and_belongs_to_many, :has_many)
        has_many_field(attr, html_options)
      elsif attr.to_s.include?('password')
        password_field(attr, html_options)
      elsif attr.to_s.include?('email')
        email_field(attr, html_options)
      elsif respond_to?(custom_field_method)
        send(custom_field_method, attr, html_options)
      else
        text_field(attr, html_options)
      end
    end

    # Render a number field.
    def number_field(attr, html_options = {})
      html_options[:size] ||= 10
      super(attr, html_options)
    end

    # Render a standard string field with column contraints.
    def string_field(attr, html_options = {})
      html_options[:maxlength] ||= column_property(@object, attr, :limit)
      html_options[:size] ||= 30
      text_field(attr, html_options)
    end

    # Render a text_area.
    def text_area(attr, html_options = {})
      html_options[:rows] ||= 5
      super(attr, html_options)
    end

    # Render a email field.
    def email_field(attr, html_options = {})
      html_options[:size] ||= 30
      super(attr, html_options)
    end

    # Render an integer field.
    def integer_field(attr, html_options = {})
      html_options[:step] ||= 1
      number_field(attr, html_options)
    end

    # Render a float field.
    def float_field(attr, html_options = {})
      html_options[:step] ||= 'any'
      number_field(attr, html_options)
    end

    # Render a decimal field.
    def decimal_field(attr, html_options = {})
      html_options[:step] ||= 'any'
      number_field(attr, html_options)
    end

    # Render a boolean field.
    def boolean_field(attr, html_options = {})
      check_box(attr, html_options)
    end

    # Render a field to select a date. You might want to customize this.
    def date_field(attr, html_options = {})
      date_select(attr, {}, html_options)
    end

    # Render a field to enter a time. You might want to customize this.
    def time_field(attr, html_options = {})
      time_select(attr, {}, html_options)
    end

    # Render a field to enter a date and time.
    # You might want to customize this.
    def datetime_field(attr, html_options = {})
      datetime_select(attr, {}, html_options)
    end

    # Render a select element for a :belongs_to association defined by attr.
    # Use additional html_options for the select element.
    # To pass a custom element list, specify the list with the :list key or
    # define an instance variable with the pluralized name of the association.
    def belongs_to_field(attr, html_options = {})
      list = association_entries(attr, html_options)
      if list.present?
        collection_select(attr, list, :id, :to_s,
                          select_options(attr, html_options),
                          html_options)
      else
        ta(:none_available, association(@object, attr))
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

    # Dispatch methods starting with 'labeled_' to render a label and the
    # corresponding input field.
    # E.g. labeled_boolean_field(:checked, :class => 'bold')
    # To add an additional help text, use the help option.
    # E.g. labeled_boolean_field(:checked, :help => 'Some Help')
    def method_missing(name, *args)
      if field_method = labeled_field_method?(name)
        build_labeled_field(field_method, *args)
      else
        super(name, *args)
      end
    end

    # Overriden to fullfill contract with method_missing 'labeled_' methods.
    def respond_to?(name)
      labeled_field_method?(name).present? || super(name)
    end

    ### VARIOUS FORM ELEMENTS

    # Render the error messages for the current form.
    def error_messages
      @template.render('shared/error_messages',
                       :errors => @object.errors,
                       :object => @object)
    end

    # Generates a help block for fields
    def help_block(text)
      content_tag(:p, text, :class => 'help-block')
    end

    # Render a submit button and a cancel link for this form.
    def standard_actions(submit_label = ti('button.save'), cancel_url = nil)
      content_tag(:div, :class => 'form-actions') do
        safe_join([submit_button(submit_label), cancel_link(cancel_url)], ' ')
      end
    end

    # Render a standard submit button with the given label.
    def submit_button(label = ti('button.save'))
      button(label, :class => 'btn btn-primary')
    end

    # Render a cancel link pointing to the given url.
    def cancel_link(url = nil)
      url ||= cancel_url
      link_to(ti('button.cancel'), url, :class => 'cancel')
    end

    # Renders a marker if the given attr has to be present.
    def required_mark(attr)
      required?(attr) ? REQUIRED_MARK : ''
    end

    # Render a label for the given attribute with the passed field html
    # section. The following parameters may be specified:
    #   labeled(:attr) { #content }
    #   labeled(:attr, content)
    #   labeled(:attr, 'Caption') { #content }
    #   labeled(:attr, 'Caption', content)
    def labeled(attr, caption_or_content = nil, content = nil,
                html_options = {}, &block)
      caption, content = extract_caption_and_content(
                           attr, caption_or_content, content, &block)
      add_css_class(html_options, 'controls')
      errors = errors_on?(attr) ? ' error' : ''

      content_tag(:div, :class => "control-group#{errors}") do
        label(attr, caption, :class => 'control-label') +
        content_tag(:div, content, html_options)
      end
    end

    # Depending if the given attribute must be present, return
    # only an initial selection prompt or a blank option, respectively.
    def select_options(attr, options = {})
      if options[:multiple]
        {}
      elsif prompt = options.delete(:prompt)
        { :prompt => prompt }
      elsif blank = options.delete(:include_blank)
        { :include_blank => blank }
      else
        assoc = association(@object, attr)
        if required?(attr)
          { :prompt => ta(:please_select, assoc) }
        else
          { :include_blank => ta(:no_entry, assoc) }
        end
      end
    end

    private

    # Returns true if attr is a non-polymorphic association.
    # If one or more macros are given, the association must be of this kind.
    def association_kind?(attr, type, *macros)
      if type == :integer || type.nil?
        assoc = association(@object, attr, *macros)
        assoc.present? && assoc.options[:polymorphic].nil?
      else
        false
      end
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
          list = assoc.klass.where(assoc.options[:conditions]).
                             order(assoc.options[:order])
        end
      end
      list
    end

    # Returns true if the given attribute must be present.
    def required?(attr)
      attr = attr.to_s
      attr, attr_id = assoc_and_id_attr(attr)
      validators = @object.class.validators_on(attr) +
                   @object.class.validators_on(attr_id)
      validators.any? do |v|
        v.kind == :presence &&
        !v.options.key?(:if) && !v.options.key?(:unless)
      end
    end

    # Returns true if any errors are found on the passed attribute or its
    # association.
    def errors_on?(attr)
      attr_plain, attr_id = assoc_and_id_attr(attr)
      @object.errors.has_key?(attr_plain.to_sym) ||
      @object.errors.has_key?(attr_id.to_sym)
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
      help = options.delete(:help)
      content = send(field_method, *(args << options))
      content << required_mark(args.first)
      content << help_block(help) if help.present?
      labeled(args.first, content)
    end

    # Get the cancel url for the given object considering options:
    # 1. Use :cancel_url_new or :cancel_url_edit option, if present
    # 2. Use :cancel_url option, if present
    def cancel_url
      url = @object.new_record? ? options[:cancel_url_new] :
                                  options[:cancel_url_edit]
      url || options[:cancel_url]
    end

  end
end