# encoding: UTF-8

module DryCrud
  module Table

    # Helper class to store column information.
    class Col #:nodoc:

      delegate :content_tag, :capture, to: :template

      attr_reader :header, :html_options, :template, :block

      def initialize(header, html_options, template, block)
        @header = header
        @html_options = html_options
        @template = template
        @block = block
      end

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
  end
end
