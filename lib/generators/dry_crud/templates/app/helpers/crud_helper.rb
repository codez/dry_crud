# Extension of StandardHelper functionality to provide a set of default
# attributes for the current model to be used in tables and forms. This helper
# is included in CrudController.
module CrudHelper

  # Renders a generic form for the current entry with :default_attrs or the
  # given attribute array, using the StandardFormBuilder. An options hash 
  # may be given as the last argument.
  # If a block is given, a custom form may be rendered and attrs is ignored.
  def crud_form(*attrs, &block)
    attrs = attrs_or_default(attrs) { default_attrs - [:created_at, :updated_at] }
    standard_form(@entry, *attrs, &block)
  end

  # Create a table of the @entries variable with the default or
  # the passed attributes in its columns. An options hash may be given
  # as the last argument.
  def crud_table(*attrs, &block)
    if block_given?
      list_table(*attrs, &block)
    else
      attrs = attrs_or_default(attrs) { default_attrs }
      list_table(*attrs) do |t|
         add_table_actions(t)
      end
    end
  end

  # Adds a set of standard action link column (show, edit, destroy) to the given table.
  def add_table_actions(table)
    action_col(table) { |e| link_table_action_show(e) }
    action_col(table) { |e| link_table_action_edit(e) }
    action_col(table) { |e| link_table_action_destroy(e) }
  end

  # Action link to show inside a table.
  def link_table_action_show(record)
    link_table_action('show', record)
  end

  # Action link to edit inside a table.
  def link_table_action_edit(record)
    link_table_action('edit', edit_polymorphic_path(record))
  end

  # Action link to destroy inside a table.
  def link_table_action_destroy(record)
    link_table_action('delete', record,
                      :confirm => ti(:confirm_delete),
                      :method => :delete)
  end

  # Generic action link inside a table.
  def link_table_action(image, url, html_options = {})
  	link_to(action_icon(image), url, html_options)
  end

  # Defines a column with an action link.
  def action_col(table, &block)
  	table.col('', :class => 'center', &block)
  end
  
  private

  # Returns default attrs for a crud table if no others are passed.
  def attrs_or_default(attrs)
  	options = attrs.extract_options!
  	attrs = yield if attrs.blank?
  	attrs << options
  end

end
