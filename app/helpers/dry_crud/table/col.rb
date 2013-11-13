# encoding: UTF-8

module DryCrud::Table
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
end
