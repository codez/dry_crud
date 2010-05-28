# A form builder that automatically selects the corresponding input field
# for ActiveRecord column types. Convenience methods for each column type allow
# one to customize the different fields. 
# All field methods may be prefixed with 'labeled_' in order to render
# a standard label with them.
class StandardFormBuilder < ActionView::Helpers::FormBuilder
  
  BLANK_SELECT_LABEL = 'Please select'
  
  attr_reader :template 
  
  delegate :belongs_to_association, :column_type, :column_property, :labeled, :captionize, 
           :to => :template
  
  # Render multiple input fields together with a label for the given attributes.
  def labeled_input_fields(*attrs)
    attrs.collect {|a| labeled_input_field(a) }.join
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
    type = column_type(@object.class, attr)
    case type
      when :text
        text_area(attr, html_options)
      when :integer
        if belongs_to_association(@object, attr)
          belongs_to_field(attr, html_options)
        else
          integer_field(attr, html_options)
        end
      else
        custom_field_method = :"#{type}_field"
        if respond_to?(custom_field_method)
          send(custom_field_method, attr, html_options)
        else
          text_field(attr, html_options)
        end
    end
  end
  
  def string_field(attr, html_options = {})
    limit = column_property(@object.class, attr, :limit)
    html_options = {:maxlength => limit}.merge(html_options) if limit
    text_field(attr, html_options)
  end
  
  # Render a standard text field.
  def text_field(attr, html_options = {})
    super(attr, {:size => 30}.merge(html_options))
  end
  
  # Render a standard text area.
  def text_area(attr, html_options = {})
    super(attr, {:rows => 5, :cols => 30}.merge(html_options))
  end
  
  # Render a standard number field.
  def number_field(attr, html_options = {})
    text_field(attr, {:size => 15}.merge(html_options))
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
  def belongs_to_field(attr, html_options = {})
    assoc = belongs_to_association(@object, attr)
    list = assoc.klass.find(:all, :conditions => assoc.options[:conditions],
        							            :order => assoc.options[:order])
    collection_select(attr, list, :id, :label, { :include_blank => BLANK_SELECT_LABEL }, html_options)
  end
  
  # Dispatch methods starting with 'labeled_' to render a label and the corresponding 
  # input field. E.g. labeled_boolean_field(:checked, {:class => 'bold'})
  def method_missing(name, *args)
    if field_method = labeled_field_method?(name)
      labeled(label(args.first), send(field_method, *args))
    else     
      super(name, *args)
    end
  end
  
  def respond_to?(name)
    labeled_field_method?(name).present? || super(name)
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
