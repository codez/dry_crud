class StandardFormBuilder < ActionView::Helpers::FormBuilder

    include StandardHelper

    DEFAULT_INPUT_OPTIONS = { }

    def initialize(*args)
        super *args
        # TODO handle object_name correctly for non-crud views
        @object_name = :entry
    end
    
    def labeled_field(attr, html_options = {})
        labeled(attr, input_field(attr, html_options))
    end
    
    def labeled_fields(*attrs)
        attrs.collect {|a| labeled_field(a) }.join
    end
        
    def input_field(attr, html_options = {})
    	options = DEFAULT_INPUT_OPTIONS.merge(html_options)
        case column_type(@object.class, attr)
            when :date 		then date_calendar_field(attr, options)
            when :boolean 	then check_box(attr, options)
            when :float, :integer then number_input_field(attr,options)
            when :text	    then text_area(attr, {:rows => 5, :cols => 30}.merge(options))
        else text_field(attr, {:size => 30}.merge(options))
        end
    end
    
    def date_calendar_field(attr, html_options = {})
        date_select(attr, {}, html_options)
    end

    def number_input_field(attr, html_options = {})
        if belongs_to_association(@object, attr)
            belongs_to_field(attr, html_options)
        else
            text_field(attr, {:size => 15}.merge(html_options))
        end
    end

    def belongs_to_field(attr, html_options = {})
        assoc = belongs_to_association(@object, attr)
        models = assoc.klass.find(:all, :conditions => assoc.options[:conditions],
        								:order => assoc.options[:order])
        collection_select(attr, models, :id, :label, { :include_blank => "Please select" }, html_options)
    end

    private
    
    def concat(e)
        @template.concat(e)
    end

    def content_tag(name, content_or_options_with_block = nil, options = nil, escape = true, &block)
        @template.content_tag(name, content_or_options_with_block, options, escape, &block)
    end
end
