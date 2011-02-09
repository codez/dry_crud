# A view helper to standartize often used functions like formatting, 
# tables, forms or action links. This helper is ideally defined in the 
# ApplicationController.
module StandardHelper
  
  NO_LIST_ENTRIES_MESSAGE = "No entries found"
  NO_ENTRY                = '(none)'
  CONFIRM_DELETE_MESSAGE  = 'Do you really want to delete this entry?'
  
  FLOAT_FORMAT = "%.2f"
  TIME_FORMAT  = "%H:%M"
  EMPTY_STRING = "&nbsp;".html_safe   # non-breaking space asserts better css styling.
  
  ################  FORMATTING HELPERS  ##################################

  # Define an array of associations symbols in your helper that should not get automatically linked.
  #def no_assoc_links = [:city]
  
  # Formats a single value
  def f(value)
    case value
      when Fixnum then number_with_delimiter(value)
      when Float  then FLOAT_FORMAT % value
      when Date   then value.to_s
      when Time   then value.strftime(TIME_FORMAT)   
      when true   then 'yes'
      when false  then 'no'
      when nil    then EMPTY_STRING
    else 
      value.respond_to?(:label) ? value.label : value.to_s
    end
  end
  
  # Formats an arbitrary attribute of the given ActiveRecord object.
  # If no specific format_{attr} method is found, formats the value as follows:
  # If the value is an associated model, renders the label of this object.
  # Otherwise, calls format_type.
  def format_attr(obj, attr)
    format_attr_method = :"format_#{attr.to_s}"
    if respond_to?(format_attr_method)
      send(format_attr_method, obj)
    elsif assoc = association(obj, attr, :belongs_to)
      format_assoc(obj, assoc)
    else
      format_type(obj, attr)
    end
  end
  
  
  ##############  STANDARD HTML SECTIONS  ############################
  
  
  # Renders an arbitrary content with the given label. Used for uniform presentation.
  def labeled(label, content = nil, &block)
    content = capture(&block) if block_given?
    render(:partial => 'shared/labeled', 
           :locals => { :label => label, :content => content}) 
  end
  
  # Transform the given text into a form as used by labels or table headers.
  def captionize(text, clazz = nil)
    if clazz.respond_to?(:human_attribute_name)
      clazz.human_attribute_name(text)
    else
      text.to_s.humanize.titleize      
    end
  end
  
  # Renders a list of attributes with label and value for a given object. 
  # Optionally surrounded with a div.
  def render_attrs(obj, *attrs)
    attrs.collect do |a| 
      labeled_attr(obj, a)
    end.join("\n").html_safe
  end
  
  # Renders the formatted content of the given attribute with a label.
  def labeled_attr(obj, attr)
    labeled(captionize(attr, obj.class), format_attr(obj, attr))
  end
  
  # Renders a table for the given entries. One column is rendered for each attribute passed. 
  # If a block is given, the columns defined therein are appended to the attribute columns.
  # If entries is empty, an appropriate message is rendered.
  def table(entries, *attrs, &block)
    if entries.present?
      StandardTableBuilder.table(entries, self) do |t|
        t.attrs(*attrs)
        yield t if block_given?
      end
    else
      content_tag(:div, NO_LIST_ENTRIES_MESSAGE, :class => 'list')
    end
  end
  
  # Renders a generic form for all given attributes using StandardFormBuilder.
  # Before the input fields, the error messages are rendered, if present.
  # The form is rendered with a basic save button.
  # If a block is given, custom input fields may be rendered and attrs is ignored.
  def standard_form(object, attrs = [], options = {}, &block)
    form_for(object, {:builder => StandardFormBuilder}.merge(options)) do |form|
      content = render(:partial => 'shared/error_messages', 
                       :locals => {:errors => object.errors})
      
      content << if block_given? 
        capture(form, &block) 
      else
        form.labeled_input_fields(*attrs)
      end
      
      content << labeled(nil, form.submit("Save") + cancel_link(object))
      content.html_safe
    end
  end
  
  def cancel_link(object)
    link_to("Cancel", polymorphic_path(object), :class => 'cancel')
  end
  
  # Alternate table row
  def tr_alt(cycle_name = 'row_class', &block)
    content_tag(:tr, :class => cycle("even", "odd", :name => cycle_name), &block)
  end
  
  def clear
    content_tag(:div, '', :class => 'clear')
  end
 
  
  ######## ACTION LINKS ###################################################### :nodoc:
  
  # Standard link action to the show page of a given record.
  def link_action_show(record)
    link_action 'Show', 'show', record
  end
  
  # Standard link action to the edit page of a given record.
  def link_action_edit(record)
    link_action 'Edit', 'edit', edit_polymorphic_path(record)
  end
  
  # Standard link action to the destroy action of a given record.
  def link_action_destroy(record)
    link_action 'Delete', 'delete', record, 
                :confirm => CONFIRM_DELETE_MESSAGE, 
                :method => :delete
  end
  
  # Standard link action to the list page.
  def link_action_index(url_options = {:action => 'index', :returning => true})
    link_action 'List', 'list', url_options
  end
  
  # Standard link action to the new page.
  def link_action_add(url_options = {:action => 'new'})
    link_action 'Add', 'add', url_options
  end
  
  # A generic helper method to create action links.
  # These link could be styled to look like buttons, for example.
  def link_action(label, icon = nil, url = {}, html_options = {})
    link_to(icon ? action_icon(icon, label) : label, 
            url, 
            {:class => 'action'}.merge(html_options))
  end
  
  def action_icon(icon, label = nil)
    html = image_tag("actions/#{icon}.png", :size => '16x16') 
    html << ' ' << label if label
    html
  end
  
  protected
  
  # Helper methods that are not directly called from templates.
  
  # Formats an active record association
  def format_assoc(obj, assoc)
    if assoc_val = obj.send(assoc.name)
      link_to_unless(no_assoc_link?(assoc, assoc_val), assoc_val.label, assoc_val)
    else
      NO_ENTRY
    end
  end
  
  # Returns true if no link should be created when formatting the given association.
  def no_assoc_link?(assoc, val)
    (respond_to?(:no_assoc_links) && no_assoc_links.to_a.include?(assoc.name.to_sym)) || 
    !respond_to?("#{val.class.name.underscore}_path".to_sym)
  end
  
  # Formats an arbitrary attribute of the given object depending on its data type.
  # For ActiveRecords, take the defined data type into account for special types
  # that have no own object class.
  def format_type(obj, attr)
    val = obj.send(attr)
    return EMPTY_STRING if val.nil?
    case column_type(obj, attr)
      when :time    then f(val.to_time)
      when :date    then f(val.to_date)
      when :datetime, :timestamp then "#{f(val.to_date)} #{f(val.to_time)}"
      when :text    then val.present? ? simple_format(h(val)) : EMPTY_STRING
      when :decimal then f(val.to_s.to_f)
      else f(val)
    end
  end
  
  # Returns the ActiveRecord column type or nil.
  def column_type(obj, attr)
    column_property(obj, attr, :type)
  end
  
  # Returns an ActiveRecord column property for the passed attr or nil
  def column_property(obj, attr, property)
    if obj.respond_to?(:column_for_attribute)
      column = obj.column_for_attribute(attr)
      column.try(property)
    end  
  end
  
  # Returns the association proxy for the given attribute. The attr parameter
  # may be the _id column or the association name. If a macro (e.g. :belongs_to)
  # is given, the association must be of this type, otherwise, any association
  # is returned. Returns nil if no association (or not of the given macro) was 
  # found.
  def association(obj, attr, macro = nil)
    if obj.class.respond_to?(:reflect_on_association)
      name = attr.to_s =~ /_id$/ ? attr.to_s[0..-4].to_sym : attr
      assoc = obj.class.reflect_on_association(name)
      assoc if assoc && (macro.nil? || assoc.macro == macro)
    end
  end
  
end