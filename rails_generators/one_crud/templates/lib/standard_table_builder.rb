class StandardTableBuilder
	attr_reader :entries, :cols, :template
  
  # Delegate called methods to template.
  # including StandardHelper would lead to problems with indirectly called methods.
	delegate :content_tag, :format_attr, :column_type, :captionize, :tr_alt, :to => :template

	def initialize(entries, template)
		@entries = entries
		@template = template
		@cols = []
  end

  def self.table(entries, template)
    t = new(entries, template)
    yield t
    t.to_html    
  end

	def col(header = '', html_options = {}, &block)
		@cols << Col.new(header, html_options, @template, block)
	end
	
	def attrs(*attrs)
		attrs.each do |a|
			col(captionize(a), :class => align_class(a)) { |e| format_attr(e, a) }
		end
	end	
	
	def align_class(attr)
		case column_type(entries.first.class, attr)
			when :integer, :float, :decimal then 'right_align'
			when :boolean	 then 'center_align'
			else nil
		end
	end
	
	def to_html
		content_tag :table, :class => 'list' do
			[html_header] + 
			entries.collect { |e| html_row(e) }
		end
	end
	
	def html_header
		content_tag :tr do
			cols.collect { |c| c.html_header }
		end
  end

	def html_row(entry)
		tr_alt do
			cols.collect { |c| c.html_cell(entry) }
		end
	end
	
	class Col < Struct.new(:header, :html_options, :template, :block)
	
		delegate :content_tag, :to => :template
	
		def content(entry)
			block.call(entry)
		end
		
		def html_header
			content_tag :th, header
		end
		
		def html_cell(entry)
			content_tag :td, content(entry), html_options
		end

  end

end