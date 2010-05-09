module CrudHelper

	# Create a table of the @entries variable with the default or 
	# the passed attributes in its columns.
	def crud_table(attrs = nil, &block)
		if block_given?
			table(@entries, &block)
		else
			table(@entries) do |l|
				l.attrs(*(attrs || default_attrs))
				add_list_actions(l)
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
    

	def default_attrs	
        attrs = model_class.column_names.collect(&:to_sym)
	    [:id].each {|a| attrs.delete(a) }
	    attrs
	end
	
	def add_list_actions(list)
		l.row { |e| link_action_show(e) }
		l.row { |e| link_action_edit(e) }
		l.row { |e| link_action_delete(e) }
	end

end
