# encoding: UTF-8

module DryCrud::Table
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
      params.merge(sort: attr, sort_dir: sort_dir(attr))
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
end
