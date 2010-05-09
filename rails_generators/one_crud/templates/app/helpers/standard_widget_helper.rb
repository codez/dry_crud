module StandardWidgetHelper

	NO_LIST_ENTRIES_MESSAGE = "No entries available"
	
	def f(value)
		case value
			when Fixnum then value.to_s
			when Float  then "%.2f" % value
			when Date	then value.strftime
			when true   then 'yes'
			when false  then 'no'
			else h value.to_s
		end
	end

	def labeled(label, &block)
		render :layout => 'standard_widget/labeled', :object => label,  &block
	end
	
	# Alternate table row
	def tr_alternate(&block)
		content_tag(:tr, :class => cycle("even", "odd", :name => "row_class"), &block)
	end
	
	def list(entries)
		if entries.present?
			list = ListHelper.new(entries, self)
			yield list
			render :partial => 'standard_widget/list', :object => list
		else
			content_tag(:div, NO_LIST_ENTRIES_MESSAGE, :class => 'list')
		end
	end
	
	
	class ListHelper
		attr_reader :entries, :cols
	
		def initialize(entries, template)
			@entries = entries
			@template = template
			@cols = []
		end
	
		def col(header = '', html_options = {}, &block)
			@cols << Col.new(header, html_options, @template, block)
		end
		
		def attrs(attrs)
			attrs.each do |a|
				col(a.to_s.humanize.titleize) { |e| @template.f(e.send(a)) }
			end
		end	
		
	 	class Col < Struct.new(:header, :html_options_hash, :template, :block)
	 		def content(entry)
	 			block.call(entry)
	 		end
	 			
	 		def html_options
	 			# use undocumented (and private) rails method
	 			template.send(:tag_options, html_options_hash)
	 		end
	 	end
	
	end
end