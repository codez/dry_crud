module CrudHelper

	CONFIRM_DELETE_MESSAGE = 'Do you really want to delete this entry'
	
	# Create a table of the @entries variable with the default or 
	# the passed attributes in its columns.
	#
	def crud_list(attrs = nil, &block)
		if block_given?
			list(@entries, &block)
		else
			list(@entries) do |l|
				l.attrs(attrs || default_attrs)
				add_list_actions(l)
			end
		end
	end

	def default_attrs
		model.content_columns
	end
	
	def add_list_actions(list)
		l.row { |e| link_to_show(e) }
		l.row { |e| link_to_edit(e) }
		l.row { |e| link_to_delete(e) }
	end
	
	def link_to_show(entry = @entry)
		link_to '[Show]', entry
	end
	
	def link_to_edit(entry = @entry)
		link_to '[Edit]', edit_polymorphic_path(entry)
	end
	
	def link_to_delete(entry = @entry)
		link_to '[Delete]', entry, :confirm => CONFIRM_DELETE_MESSAGE, :method => :delete
	end
	
	def link_to_index
		link_to '[List]', :action => 'index'
	end
	
	def link_to_add
		link_to '[Add]', :action => 'new'
	end

end
