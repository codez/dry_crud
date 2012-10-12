# Extension of StandardHelper functionality to provide a set of default
# attributes for the current model to be used in tables and forms. This helper
# is included in CrudController.
module CrudHelper

  # Renders a crud form for the current entry with default_attrs or the
  # given attribute array. An options hash may be given as the last argument.
  # If a block is given, a custom form may be rendered and attrs is ignored.
  def entry_form(*attrs, &block)
    options = attrs.extract_options!
    attrs = default_attrs - [:created_at, :updated_at] if attrs.blank?
    attrs << options
    crud_form(path_args(entry), *attrs, &block)
  end

  # Renders a standard form for the given entry and attributes.
  # The form is rendered with a basic save and cancel button.
  # If a block is given, custom input fields may be rendered and attrs is ignored. 
  # An options hash may be given as the last argument.
  def crud_form(object, *attrs, &block)
    options = attrs.extract_options!
    cancel_url = get_cancel_url(object, options)
    
    standard_form(object, options) do |form|
      content = if block_given?
        capture(form, &block)
      else
        form.labeled_input_fields(*attrs)
      end

      content << form.standard_actions(cancel_url)
      content.html_safe
    end
  end

  # Create a table of the current entries with the default or the passed 
  # attributes in its columns. 
  # If attrs are present, the first column will link to the show
  # action. Edit and destroy actions are appended to the end of each row.
  # If a block is given, the column defined there will be inserted
  # between the given attributes and the actions.
  # An options hash for the table builder may be given as the last argument.
  def crud_table(*attrs, &block)
    options = attrs.extract_options!
    attributes = (block_given? || attrs.present?) ? attrs : default_attrs
    first = attributes.shift
    table(entries, options) do |t|
       col_show(t, first) if first
       t.sortable_attrs(*attributes)
       yield t if block_given?
       add_table_actions(t)
    end
  end

  # Adds a set of standard action link column (show, edit, destroy) to the given table.
  def add_table_actions(table)
    action_col_edit(table)
    action_col_destroy(table)
  end
  
  # Renders the passed attr with a link to the show action for
  # the current entry.
  # A block may be given to define the link path for the row entry.
  def col_show(table, attr, &block)
    table.attr(attr, table.sort_header(attr)) do |e| 
      link_to(format_attr(e, attr), action_path(e, &block))
    end
  end

  # Action link to show the row entry inside a table.
  # A block may be given to define the link path for the row entry.
  def action_col_show(table, &block)
    action_col(table) do |e| 
      link_table_action('zoom-in', action_path(e, &block))
    end
  end

  # Action link to edit inside a table.
  # A block may be given to define the link path for the row entry.
  def action_col_edit(table, &block)
    action_col(table) do |e|
      path = action_path(e, &block)
      link_table_action('pencil', path.is_a?(String) ? path : edit_polymorphic_path(path))
    end
  end

  # Action link to destroy inside a table.
  # A block may be given to define the link path for the row entry.
  def action_col_destroy(table, &block)
    action_col(table) do |e|
      link_table_action('remove', action_path(e, &block),
                        :data => { :confirm => ti(:confirm_delete),
                                   :method => :delete })
    end
  end

  # Generic action link inside a table.
  def link_table_action(icon, url, html_options = {})
    add_css_class html_options, "icon-#{icon}"
    link_to('', url, html_options)
  end

  # Defines a column with an action link.
  def action_col(table, &block)
    table.col('', :class => 'action', &block)
  end

  ######## ACTION LINKS ###################################################### :nodoc:

  # Standard link action to the show page of a given record.
  # Uses the current record if none is given.
  def link_action_show(path = nil)
    path ||= path_args(entry)
    link_action ti(:"link.show"), 'zoom-in', path
  end

  # Standard link action to the edit page of a given record.
  # Uses the current record if none is given.
  def link_action_edit(path = nil)
    path ||= path_args(entry)
    link_action ti(:"link.edit"), 'pencil', path.is_a?(String) ? path : edit_polymorphic_path(path)
  end

  # Standard link action to the destroy action of a given record.
  # Uses the current record if none is given.
  def link_action_destroy(path = nil)
    path ||= path_args(entry)
    link_action ti(:"link.delete"), 'remove', path,
                :data => { :confirm => ti(:confirm_delete),
                           :method => :delete }
  end

  # Standard link action to the list page.
  # Links to the current model_class if no path is given.
  def link_action_index(path = nil, url_options = {:returning => true})
    path ||= path_args(model_class)
    link_action ti(:"link.list"), 'list', path.is_a?(String) ? path : polymorphic_path(path, url_options)
  end

  # Standard link action to the new page.
  # Links to the current model_class if no path is given.
  def link_action_add(path = nil, url_options = {})
    path ||= path_args(model_class)
    link_action ti(:"link.add"), 'plus', path.is_a?(String) ? path : new_polymorphic_path(path, url_options)
  end

  private

  # Get the cancel url for the given object considering options:
  # 1. Use :cancel_url_new or :cancel_url_edit option, if present
  # 2. Use :cancel_url option, if present
  # 3. Use polymorphic_path(object)
  def get_cancel_url(object, options)
    record = Array(object).last
    cancel_url = options.delete(:cancel_url)
    cancel_url_new = options.delete(:cancel_url_new)
    cancel_url_edit = options.delete(:cancel_url_edit)
    url = record.new_record? ? cancel_url_new : cancel_url_edit
    url || cancel_url || polymorphic_path(object, :returning => true)
  end

  # If a block is given, call it to get the path for the current row entry.
  # Otherwise, return the standard path args.
  def action_path(e, &block)
    block_given? ? yield(e) : path_args(e)
  end

end
