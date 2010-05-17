module CrudHelper
  
  # Create a table of the @entries variable with the default or 
  # the passed attributes in its columns.
  def crud_table(attrs = nil, &block)
    if block_given?
      table(@entries, &block)
    else
      table(@entries) do |t|
        t.attrs(*(attrs || default_attrs))
        add_list_actions(t)
      end
    end
  end
  
  # Renders a generic form for all given attributes using CrudFormBuilder.
  # If a block is given, a custom form may be rendered.
  def crud_form(attrs = nil, options = {}, &block)
    unless attrs
      attrs = default_attrs
      [:created_at, :updated_at].each {|a| attrs.delete(a) }
    end		
    form(@entry, attrs, &block)
  end
  
  # The default attributes to use in attrs, list and form partials.
  # These are all defined attributes except certain special ones like 'id'.
  def default_attrs	
    attrs = model_class.column_names.collect(&:to_sym)
    [:id].each {|a| attrs.delete(a) }
    attrs
  end
  
  def add_list_actions(table)
    table.col { |e| link_action_show(e) }
    table.col { |e| link_action_edit(e) }
    table.col { |e| link_action_destroy(e) }
  end
  
end
