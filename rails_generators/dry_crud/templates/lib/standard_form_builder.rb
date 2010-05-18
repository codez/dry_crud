# A form builder that automatically selects the corresponding input element
# for ActiveRecord attributes. Input elements are rendered with a corresponding
# label by default.
class StandardFormBuilder < ActionView::Helpers::FormBuilder
  
  attr_reader :template 
  
  delegate :belongs_to_association, :column_type, :labeled, :captionize, 
           :to => :template
  
  DEFAULT_INPUT_OPTIONS = { }
  
  # Render the input field together with a label for the given attribute.
  # Use additional html_options for the input element.
  def labeled_field(attr, html_options = {})
    labeled(label(attr, captionize(attr, @object.class)), input_field(attr, html_options))
  end
  
  # Render input fields together with a label for the given attributes.
  def labeled_fields(*attrs)
    attrs.collect {|a| labeled_field(a) }.join
  end
  
  # Render a corresponding input field for the given attribute.
  # Use additional html_options for the input element.
  def input_field(attr, html_options = {})
    options = DEFAULT_INPUT_OPTIONS.merge(html_options)
    case column_type(@object.class, attr)
      when :date  # existing as well: :datetime, :timestamp, :time
        date_calendar_field(attr, options)
      when :boolean 
        check_box(attr, options)
      when :float, :integer, :decimal 
        if belongs_to_association(@object, attr)
          belongs_to_field(attr, html_options)
        else
          text_field(attr, {:size => 15}.merge(html_options))
        end
      when :text 
        text_area(attr, {:rows => 5, :cols => 30}.merge(options))
      else 
        text_field(attr, {:size => 30}.merge(options))
    end
  end
  
  # Render a field to select a date. You might want to customize this.
  def date_calendar_field(attr, html_options = {})
    date_select(attr, {}, html_options)
  end
  
  # Render a select element for a :belongs_to association defined by attr.
  # Use additional html_options for the select element.
  def belongs_to_field(attr, html_options = {})
    assoc = belongs_to_association(@object, attr)
    list = assoc.klass.find(:all, :conditions => assoc.options[:conditions],
        							            :order => assoc.options[:order])
    collection_select(attr, list, :id, :label, { :include_blank => "Please select" }, html_options)
  end
  
end
