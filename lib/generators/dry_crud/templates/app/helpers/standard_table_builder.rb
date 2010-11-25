# A simple helper to easily define tables listing several rows of the same data type.
#
# Example Usage:
#   StandardTableBuilder.table(entries, template) do |t|
#     t.col('My Header', :class => 'css') {|e| link_to 'Show', e }
#     t.attrs :name, :city
#   end
class StandardTableBuilder
  attr_reader :entries, :cols, :template
  
  # Delegate called methods to template.
  # including StandardHelper would lead to problems with indirectly called methods.
  delegate :content_tag, :format_attr, :column_type, :association, 
           :captionize, :tr_alt, :to => :template

  def initialize(entries, template)
    @entries = entries
    @template = template
    @cols = []
  end

  # Convenience method to directly generate a table. Renders a row for each entry in entries.
  # Takes a block that gets the table object as parameter for configuration.
  # Returns the generated html for the table.
  def self.table(entries, template)
    t = new(entries, template)
    yield t
    t.to_html
  end

  # Define a column for the table with the given header, the html_options used for
  # each td and a block rendering the contents of a cell for the current entry.
  # The columns appear in the order they are defined.
  def col(header = '', html_options = {}, &block)
    @cols << Col.new(header, html_options, @template, block)
  end
  
  # Convenience method to add one or more attribute columns.
  # The attribute name will become the header, the cells will contain
  # the formatted attribute value for the current entry.
  def attrs(*attrs)
    attrs.each do |a|
      attr(a)
    end
  end
  
  # Define a column for the given attribute and an optional header.
  # If no header is given, the attribute name is used. The cell will
  # contain the formatted attribute value for the current entry.
  def attr(a, header = nil)
    header ||= attr_header(a)
    col(header, :class => align_class(a)) { |e| format_attr(e, a) }
  end
  
  # Renders the table as HTML.
  def to_html
    content_tag :table, :class => 'list' do
      html_header + entries.collect { |e| html_row(e) }.join.html_safe
    end
  end
  
  # Returns css classes used for alignment of the cell data.
  # Based on the column type of the attribute.
  def align_class(attr)
    entry = entries.first
    case column_type(entry, attr)
      when :integer, :float, :decimal 
        'right_align' unless association(entry, attr, :belongs_to)
      when :boolean  
        'center_align'
    end
  end
  
  def attr_header(attr)
    captionize(attr, entry_class)
  end
  
  private 
  
  def html_header
    content_tag :tr do
      cols.collect { |c| c.html_header }.join.html_safe
    end
  end

  def html_row(entry)
    tr_alt do
      cols.collect { |c| c.html_cell(entry) }.join.html_safe
    end
  end

  def entry_class
    entries.first.class
  end
  
  # Helper class to store column information.
  class Col < Struct.new(:header, :html_options, :template, :block) #:nodoc:
  
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
  
  module Sorting
    # Create a header with sort links
    def sort_header(attr, label = nil)
      label ||= attr_header(attr)
      template.link_to(label, sort_params(attr)) + current_mark(attr)
    end
    
    def sortable_attrs(*attrs)
      attrs.each do |a|
        sortable_attr(a)
      end
    end
    
    def sortable_attr(a, header = nil)
      template.sortable?(a) ? attr(a, sort_header(a, header)) : attr(a, header)
    end
    
    private
    
    def sort_params(attr)
      # include :page parameter preventatively
      params.merge({:sort => attr, :sort_dir => sort_dir(attr), :page => 1})
    end
    
    def current_mark(attr)
      if current_sort?(attr) 
        (sort_dir(attr) == 'asc' ? ' &uarr;' : ' &darr;').html_safe
      else
        ''
      end
    end
    
    def current_sort?(attr)
      params[:sort] == attr.to_s
    end
    
    def sort_dir(attr)
      current_sort?(attr) && params[:sort_dir] == 'asc' ? 'desc' : 'asc'
    end
    
    def params
      template.params
    end
  end
  
  include Sorting

end