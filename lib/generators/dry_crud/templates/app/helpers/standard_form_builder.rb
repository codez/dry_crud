# A form builder that automatically selects the corresponding input field
# for ActiveRecord column types. Convenience methods for each column type allow
# one to customize the different fields. 
# All field methods may be prefixed with 'labeled_' in order to render
# a standard label with them.
class StandardFormBuilder < ActionView::Helpers::FormBuilder
  
  BLANK_SELECT_LABEL = 'Please select'
  REQUIRED_MARK    = '<span class="required">*</span>'.html_safe
  
  attr_reader :template 
  
  delegate :association, :column_type, :column_property, :captionize, 
           :to => :template
  
  # Render multiple input fields together with a label for the given attributes.
  def labeled_input_fields(*attrs)
    attrs.collect {|a| labeled_input_field(a) }.join("\n").html_safe
  end
  
  # Render a standartized label.
  def label(attr, text = nil, options = {})
    if attr.is_a?(Symbol) && text.nil? && options.blank?
      super(attr, captionize(attr, @object.class))
    else
      super(attr, text, options)
    end
  end
  
  # Render a corresponding input field for the given attribute.
  # The input field is chosen based on the ActiveRecord column type.
  # Use additional html_options for the input element.
  def input_field(attr, html_options = {})
    type = column_type(@object, attr)
    if type == :text
      text_area(attr, html_options)
    elsif belongs_to_association?(attr, type)
      belongs_to_field(attr, html_options)
    elsif attr.to_s.include?('password')
      password_field(attr, html_options)
    else
      custom_field_method = :"#{type}_field"
      if respond_to?(custom_field_method)
        send(custom_field_method, attr, html_options)
      else
        text_field(attr, html_options)
      end
    end
  end
  
  # Render a standard text field.
  def text_field(attr, html_options = {})
    super(attr, {:size => 30}.merge(html_options))
  end
  
  # Render a standard password field.
  def password_field(attr, html_options = {})
    super(attr, {:size => 30}.merge(html_options))
  end
  
  # Render a standard text area.
  def text_area(attr, html_options = {})
    super(attr, {:rows => 5, :cols => 30}.merge(html_options))
  end
  
  # Render a standard string field with column contraints.
  def string_field(attr, html_options = {})
    limit = column_property(@object, attr, :limit)
    html_options = {:maxlength => limit}.merge(html_options) if limit
    text_field(attr, html_options)
  end
  
  # Render a standard number field.
  def number_field(attr, html_options = {})
    super(attr, {:size => 15}.merge(html_options))
  end
  
  # Render an integer field.
  def integer_field(attr, html_options = {})
    number_field(attr, html_options)
  end
  
  # Render a float field.
  def float_field(attr, html_options = {})
    number_field(attr, html_options)
  end 
  
  # Render a decimal field.
  def decimal_field(attr, html_options = {})
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
  
  # Render a select element for a :belongs_to association defined by attr.
  # Use additional html_options for the select element.
  # To pass a custom element list, specify the list with the :list key or
  # define an instance variable with the pluralized name of the association.
  def belongs_to_field(attr, html_options = {})
    list = association_entries(attr, html_options)
    if list.present?
      collection_select(attr, list, :id, :label, select_options(attr), html_options)
    else
      '(none available)'
    end
  end
  
  # Renders a marker if the given attr has to be present.
  def required_mark(attr)
    required?(attr) ? REQUIRED_MARK : ''
  end
  
  # Render a label for the given attribute with the passed field html section.
  def labeled(attr, field_html = nil, &block)
    template.labeled(label(attr), field_html, &block)
  end
  
  # Dispatch methods starting with 'labeled_' to render a label and the corresponding 
  # input field. E.g. labeled_boolean_field(:checked, {:class => 'bold'})
  def method_missing(name, *args)
    if field_method = labeled_field_method?(name)
      labeled(args.first, send(field_method, *args) + required_mark(args.first))
    else     
      super(name, *args)
    end
  end
  
  def respond_to?(name)
    labeled_field_method?(name).present? || super(name)
  end
  
  protected
  
  # Returns true if attr is a non-polymorphic belongs_to association,
  # for which an input field may be automatically rendered.
  def belongs_to_association?(attr, type)
    if type == :integer || type.nil?
      assoc = association(@object, attr, :belongs_to)
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
      list = @template.send(:instance_variable_get, :"@#{assoc.name.to_s.pluralize}")
      unless list
        list = assoc.klass.all(:conditions => assoc.options[:conditions],
                               :order => assoc.options[:order])
      end
    end
    list
  end
  
  # Returns true if the given attribute must be present.
  def required?(attr)
    attr = attr.to_s
    attr, attr_id = attr.end_with?('_id') ? [attr[0..-4], attr] : [attr, "#{attr}_id"]
    validators = @object.class.validators_on(attr) + 
                 @object.class.validators_on(attr_id)
    validators.any? {|v| v.kind == :presence }
  end
  
  # Depending if the given attribute must be present, return
  # only an initial selection prompt or a blank option, respectively.
  def select_options(attr)
    required?(attr) ? { :prompt => BLANK_SELECT_LABEL } : 
                      { :include_blank => StandardHelper::NO_ENTRY }
  end
  
  private
  
  def labeled_field_method?(name)
    prefix = 'labeled_'
    if name.to_s.start_with?(prefix)
      field_method = name.to_s[prefix.size..-1]
      field_method if respond_to?(field_method)
    end
  end
  
end
