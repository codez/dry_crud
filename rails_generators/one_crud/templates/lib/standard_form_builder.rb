class StandardFormBuilder < ActionView::Helpers::FormBuilder
  
  attr_reader :template 
  
  delegate :belongs_to_association, :column_type, :labeled, :captionize, 
           :to => :template
  
  DEFAULT_INPUT_OPTIONS = { }
  
  def labeled_field(attr, html_options = {})
    labeled(label(attr, captionize(attr)), input_field(attr, html_options))
  end
  
  def labeled_fields(*attrs)
    attrs.collect {|a| labeled_field(a) }.join
  end
  
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
  
  def date_calendar_field(attr, html_options = {})
    date_select(attr, {}, html_options)
  end
  
  def belongs_to_field(attr, html_options = {})
    assoc = belongs_to_association(@object, attr)
    list = assoc.klass.find(:all, :conditions => assoc.options[:conditions],
        							            :order => assoc.options[:order])
    collection_select(attr, list, :id, :label, { :include_blank => "Please select" }, html_options)
  end
  
end
