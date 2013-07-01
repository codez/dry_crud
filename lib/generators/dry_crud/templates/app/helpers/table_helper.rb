# Defines tables to display a list of entries. The helper methods come in different granularities:
# * <tt>#table</tt> - A basic table for the given entries and attributes using the Crud::TableBuilder.
# * <tt>#list_table</tt> - A sortable #table for the current #entries, with the given attributes or default.
# * <tt>#crud_table</tt> - A sortable #table for the current #entries, with the given attributes or default and the standard crud action links.
module TableHelper

  # Renders a table for the given entries. One column is rendered for each attribute passed.
  # If a block is given, the columns defined therein are appended to the attribute columns.
  # If entries is empty, an appropriate message is rendered.
  # An options hash may be given as the last argument.
  def table(entries, *attrs, &block)
    entries.to_a # force evaluation of relations
    if entries.present?
      options = attrs.extract_options!
      add_css_class(options, 'table')
      Crud::TableBuilder.table(entries, self, options) do |t|
        t.attrs(*attrs)
        yield t if block_given?
      end
    else
      content_tag(:div, ti(:no_list_entries), :class => 'table')
    end
  end

  # Create a table of the entries with the default or
  # the passed attributes in its columns. An options hash may be given
  # as the last argument.
  def list_table(*attrs, &block)
    options = attrs.extract_options!
    # only use default attrs if no attrs and no block are given
    attributes = (block_given? || attrs.present?) ? attrs : default_crud_attrs
    table(entries, options) do |t|
      t.sortable_attrs(*attributes)
      yield t if block_given?
    end
  end

  # Create a table of the current entries with the default or the passed
  # attributes in its columns. Edit and destroy actions are added to each row.
  # If attrs are present, the first column will link to the show
  # action. Edit and destroy actions are appended to the end of each row.
  # If a block is given, the column defined there will be inserted
  # between the given attributes and the actions.
  # An options hash for the table builder may be given as the last argument.
  def crud_table(*attrs, &block)
    options = attrs.extract_options!
    attributes = (block_given? || attrs.present?) ? attrs : default_crud_attrs
    first = attributes.shift
    table(entries, options) do |t|
       t.attr_with_show_link(first) if first
       t.sortable_attrs(*attributes)
       yield t if block_given?
       standard_table_actions(t)
    end
  end

  # Adds a set of standard action link column (edit, destroy) to the given table.
  def standard_table_actions(table)
    table.edit_action_col
    table.destroy_action_col
  end

end