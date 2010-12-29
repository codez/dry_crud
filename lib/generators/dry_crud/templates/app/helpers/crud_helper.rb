# Extension of StandardHelper functionality to provide a set of default 
# attributes for the current model to be used in tables and forms. This helper
# is included in CrudController.
module CrudHelper
  
  # Create a table of the @entries variable with the default or 
  # the passed attributes in its columns.
  def crud_table(*attrs, &block)
    if block_given?
      list_table(*attrs, &block)
    else      
      attrs = default_attrs if attrs.blank?
      list_table(*attrs) do |t| 
         add_list_actions(t)
      end
    end
  end
  
  # Adds a set of standard action link column (show, edit, destroy) to the given table.
  def add_list_actions(table)
    table.col('', :class => 'center') { |e| link_action_show(e) }
    table.col('', :class => 'center') { |e| link_action_edit(e) }
    table.col('', :class => 'center') { |e| link_action_destroy(e) }
  end
  
  # Renders a generic form for the current entry with :default_attrs or the 
  # given attribute array, using the StandardFormBuilder.
  # If a block is given, a custom form may be rendered and attrs is ignored.
  def crud_form(attrs = nil, options = {}, &block)
    unless attrs
      attrs = default_attrs
      [:created_at, :updated_at].each {|a| attrs.delete(a) }
    end		
    standard_form(@entry, attrs, &block)
  end
  
end
