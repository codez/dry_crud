module StandardHelper
  
  NO_LIST_ENTRIES_MESSAGE = "No entries available"
  CONFIRM_DELETE_MESSAGE  = 'Do you really want to delete this entry?'
  
  ################  FORMATTING HELPERS  ##################################

  # Define an array of associations symbols that should not get automatically linked.
  #def no_assoc_links = [:city]
  
  # Formats a single value
  def f(value)
    case value
      when Fixnum then value.to_s
      when Float  then "%.2f" % value
			when Date	  then value.strftime
      when true   then 'yes'
      when false  then 'no'
      when ActiveRecord::Base then h value.label
    else h value.to_s
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
    elsif assoc = belongs_to_association(obj, attr)
      format_assoc(obj, assoc)
    else
      format_type(obj, attr)
    end
  end
  
  # Formats an active record association
  def format_assoc(obj, assoc)
    if assoc_val = obj.send(assoc.name)
      if respond_to?(:no_assoc_links) && 
        no_assoc_links.to_a.include?(assoc.name.to_sym) || 
        !respond_to?("#{assoc_val.class.name.underscore}_path".to_sym)
        h assoc_val.label 
      else
        link_to(h(assoc_val.label), assoc_val)
      end
    else
			'(none)'
    end
  end
  
  # Formats an arbitrary attribute of the given object depending on its data type.
  # For ActiveRecords, take the defined data type into account for special types
  # that have no own object class.
  def format_type(obj, attr)
    val = obj.send(attr)
    return "" if val.nil?
    case column_type(obj.class, attr)
      when :time then val.strftime("%H:%M")
      when :date then val.to_date.to_s
      when :text then simple_format(h(val))
    else f(val)
    end
  end
  
  # Returns the ActiveRecord column type or nil.
  def column_type(clazz, attr)
    if clazz.respond_to?(:columns_hash)
      column = clazz.columns_hash[attr.to_s]
      column ? column.type : nil
    end    
  end
  
  # Returns the :belongs_to association for the given attribute or nil if there is none.
  def belongs_to_association(obj, attr)
    if attr.to_s =~ /_id$/ && obj.class.respond_to?(:reflect_on_all_associations)
      obj.class.reflect_on_all_associations(:belongs_to).find do |a| 
        a.primary_key_name == attr.to_s && !a.options[:polymorphic]
      end
    end
  end
  
  
  ##############  STANDARD HTML SECTIONS  ############################
  
  
  # Renders an arbitrary content with the given label. Used for uniform presentation.
  def labeled(label, content = nil, &block)
    block = lambda { content } unless block_given?
    render :layout => 'standard/labeled', :locals => {:caption => label},  &block
  end
  
  # renders a list of attributes, optionally surrounded with a div.
  def render_attrs(obj, attrs, div = true)
    html = attrs.collect do |a| 
      labeled(a.to_s.humanize.titleize, format_attr(obj, a))
    end.join
    
    if div
      content_tag(:div, html, :class => 'attributes')
    else
      html
    end
  end
  
  def table(entries, &block)
    if entries.present?
      StandardTableBuilder.table(entries, self, &block)
    else
      content_tag(:div, NO_LIST_ENTRIES_MESSAGE, :class => 'list')
    end
  end
  
  # Renders a generic form for all given attributes using StandardFormBuilder.
  # If a block is given, a custom form may be rendered.
  def form(object, attrs = [], options = {})
    form_for(object, {:builder => StandardFormBuilder}.merge(options)) do |form|
      concat form.error_messages
      
      if block_given? 
        yield(form)
      else
        concat form.labeled_fields(*attrs)
      end
      
      concat form.submit("Save")
    end
  end
  
  # Alternate table row
  def tr_alt(&block)
    content_tag(:tr, :class => cycle("even", "odd", :name => "row_class"), &block)
  end
  
  # Intermediate method to use the render_generic module. 
  # Because ActionView has a different :render method than ActionController, 
  # this method provides an entry point to use render_generic from views.
  # Strictly, this method would belong into a render_generic helper.
  def render_generic(options)                
    render_generic_partial_options(options) if options[:partial]  
    render options
  end   
 
  
  ######## ACTION LINKS ######################################################
  
  def link_action_show(entry)
    link_action 'Show', entry
  end
  
  def link_action_edit(entry)
    link_action 'Edit', edit_polymorphic_path(entry)
  end
  
  def link_action_delete(entry)
    link_action 'Delete', entry, :confirm => CONFIRM_DELETE_MESSAGE, :method => :delete
  end
  
  def link_action_index
    link_action 'List', :action => 'index'
  end
  
  def link_action_add
    link_action 'Add', :action => 'new'
  end
  
  def link_action(label, *args)
    link_to("[#{label}]", *args)
  end
  
end