# Extension of StandardHelper functionality to provide a set of default 
# attributes for the current model to be used in tables and forms. This helper
# is included in CrudController.
module ListHelper
  
  # Create a table of the @entries variable with the default or 
  # the passed attributes in its columns.
  def list_table(*attrs, &block)
    # only use default attrs if no attrs and no block are given
    attributes = (block_given? || attrs.present?) ? attrs : default_attrs
    table(@entries) do |t|
  	  t.sortable_attrs(*attributes)	  
  	  yield t if block_given? 
    end
  end
    
  # The default attributes to use in attrs, list and form partials.
  # These are all defined attributes except certain special ones like 'id' or 'position'.
  def default_attrs	
    attrs = model_class.column_names.collect(&:to_sym)
    attrs - [:id, :position, :password]
  end
    
end
