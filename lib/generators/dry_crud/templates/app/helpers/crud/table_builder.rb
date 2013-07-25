# encoding: UTF-8

module Crud
  # A simple helper to easily define tables listing several rows of the same
  # data type.
  #
  # Example Usage:
  #   Crud::TableBuilder.table(entries, template) do |t|
  #     t.col('My Header', class: 'css') {|e| link_to 'Show', e }
  #     t.attrs :name, :city
  #   end
  class TableBuilder
    attr_reader :entries, :cols, :options, :template

    delegate :content_tag, :format_attr, :column_type, :association, :dom_id,
             :captionize, :add_css_class, :content_tag_nested,
             to: :template

    def initialize(entries, template, options = {})
      @entries = entries
      @template = template
      @options = options
      @cols = []
    end

    # Convenience method to directly generate a table. Renders a row for each
    # entry in entries. Takes a block that gets the table object as parameter
    # for configuration. Returns the generated html for the table.
    def self.table(entries, template, options = {})
      t = new(entries, template, options)
      yield t
      t.to_html
    end

    # Define a column for the table with the given header, the html_options
    # used for each td and a block rendering the contents of a cell for the
    # current entry. The columns appear in the order they are defined.
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
    def attr(a, header = nil, html_options = {}, &block)
      header ||= attr_header(a)
      block ||= ->(e) { format_attr(e, a) }
      add_css_class(html_options, align_class(a))
      col(header, html_options, &block)
    end

    # Renders the table as HTML.
    def to_html
      content_tag :table, options do
        content_tag(:thead, html_header) +
        content_tag_nested(:tbody, entries) { |e| html_row(e) }
      end
    end

    # Returns css classes used for alignment of the cell data.
    # Based on the column type of the attribute.
    def align_class(attr)
      entry = entries.present? ? entry_class.new : nil
      case column_type(entry, attr)
      when :integer, :float, :decimal
        'right' unless association(entry, attr, :belongs_to)
      when :boolean
        'center'
      end
    end

    # Creates a header string for the given attr.
    def attr_header(attr)
      captionize(attr, entry_class)
    end

    private

    # Renders the header row of the table.
    def html_header
      content_tag_nested(:tr, cols) { |c| c.html_header }
    end

    # Renders a table row for the given entry.
    def html_row(entry)
      attrs = {}
      attrs[:id] = dom_id(entry) if entry.respond_to?(:to_key)
      content_tag_nested(:tr, cols, attrs) { |c| c.html_cell(entry) }
    end

    # Determines the class of the table entries.
    # All entries should be of the same type.
    def entry_class
      if entries.respond_to?(:klass)
        entries.klass
      else
        entries.first.class
      end
    end

    # Helper class to store column information.
    class Col < Struct.new(:header, :html_options, :template, :block) #:nodoc:

      delegate :content_tag, :capture, to: :template

      # Runs the Col block for the given entry.
      def content(entry)
        entry.nil? ? '' : capture(entry, &block)
      end

      # Renders the header cell of the Col.
      def html_header
        content_tag(:th, header, html_options)
      end

      # Renders a table cell for the given entry.
      def html_cell(entry)
        content_tag(:td, content(entry), html_options)
      end

    end

    # Provides headers with sort links. Expects a method :sortable?(attr)
    # in the template/controller to tell if an attribute is sortable or not.
    # Extracted into an own module for convenience.
    module Sorting
      # Create a header with sort links and a mark for the current sort
      # direction.
      def sort_header(attr, label = nil)
        label ||= attr_header(attr)
        template.link_to(label, sort_params(attr)) + current_mark(attr)
      end

      # Same as :attrs, except that it renders a sort link in the header
      # if an attr is sortable.
      def sortable_attrs(*attrs)
        attrs.each { |a| sortable_attr(a) }
      end

      # Renders a sort link header, otherwise similar to :attr.
      def sortable_attr(a, header = nil, &block)
        if template.sortable?(a)
          attr(a, sort_header(a, header), &block)
        else
          attr(a, header, &block)
        end
      end

      private

      # Request params for the sort link.
      def sort_params(attr)
        params.merge({ sort: attr, sort_dir: sort_dir(attr) })
      end

      # The sort mark, if any, for the given attribute.
      def current_mark(attr)
        if current_sort?(attr)
          (sort_dir(attr) == 'asc' ? ' &uarr;' : ' &darr;').html_safe
        else
          ''
        end
      end

      # Returns true if the given attribute is the current sort column.
      def current_sort?(attr)
        params[:sort] == attr.to_s
      end

      # The sort direction to use in the sort link for the given attribute.
      def sort_dir(attr)
        current_sort?(attr) && params[:sort_dir] == 'asc' ? 'desc' : 'asc'
      end

      # Delegate to template.
      def params
        template.params
      end
    end

    include Sorting

    # Adds action columns to the table builder.
    # Predefined actions are available for show, edit and destroy.
    # Additionally, a special col type to define cells linked to the show page
    # of the row entry is provided.
    module Actions
      extend ActiveSupport::Concern

      included do
        delegate :link_to, :path_args, :edit_polymorphic_path, :ti,
                 to: :template
      end

      # Renders the passed attr with a link to the show action for
      # the current entry.
      # A block may be given to define the link path for the row entry.
      def attr_with_show_link(attr, &block)
        sortable_attr(attr) do |e|
          link_to(format_attr(e, attr), action_path(e, &block))
        end
      end

      # Action column to show the row entry.
      # A block may be given to define the link path for the row entry.
      # If the block returns nil, no link is rendered.
      def show_action_col(html_options = {}, &block)
        action_col do |e|
          path = action_path(e, &block)
          if path
            table_action_link('zoom-in',
                              path,
                              html_options)
          end
        end
      end

      # Action column to edit the row entry.
      # A block may be given to define the link path for the row entry.
      # If the block returns nil, no link is rendered.
      def edit_action_col(html_options = {}, &block)
        action_col do |e|
          path = action_path(e, &block)
          if path
            path = path.is_a?(String) ? path : edit_polymorphic_path(path)
            table_action_link('pencil', path, html_options)
          end
        end
      end

      # Action column to destroy the row entry.
      # A block may be given to define the link path for the row entry.
      # If the block returns nil, no link is rendered.
      def destroy_action_col(html_options = {}, &block)
        action_col do |e|
          path = action_path(e, &block)
          if path
            table_action_link('remove',
                              path,
                              html_options.merge(
                                data: { confirm: ti(:confirm_delete),
                                        method: :delete }))
          end
        end
      end

      # Action column inside a table. No header.
      # The cell content should be defined in the passed block.
      def action_col(&block)
        col('', class: 'action', &block)
      end

      # Generic action link inside a table.
      def table_action_link(icon, url, html_options = {})
        add_css_class(html_options, "icon-#{icon}")
        link_to('', url, html_options)
      end

      private

      # If a block is given, call it to get the path for the current row entry.
      # Otherwise, return the standard path args.
      def action_path(e, &block)
        block_given? ? yield(e) : path_args(e)
      end
    end

    include Actions

  end
end