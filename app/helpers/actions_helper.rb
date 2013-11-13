# encoding: UTF-8

# Helpers to create action links. This default implementation supports
# regular links with an icon and a label. To change the general style
# of action links, change the method #action_link, e.g. to generate a button.
# The common crud actions show, edit, destroy, index and add are provided here.
module ActionsHelper

  # A generic helper method to create action links.
  # These link could be styled to look like buttons, for example.
  def action_link(label, icon = nil, url = {}, html_options = {})
    add_css_class html_options, 'action btn btn-default'
    link_to(icon ? action_icon(icon, label) : label,
            url, html_options)
  end

  # Outputs an icon for an action with an optional label.
  def action_icon(icon, label = nil)
    html = content_tag(:span, '', class: "icon icon-#{icon}")
    html << ' ' << label if label
    html
  end

  # Standard show action to the given path.
  # Uses the current +entry+ if no path is given.
  def show_action_link(path = nil)
    path ||= path_args(entry)
    action_link(ti('link.show'), 'zoom-in', path)
  end

  # Standard edit action to given path.
  # Uses the current +entry+ if no path is given.
  def edit_action_link(path = nil)
    path ||= path_args(entry)
    path = path.is_a?(String) ? path : edit_polymorphic_path(path)
    action_link(ti('link.edit'), 'pencil', path)
  end

  # Standard destroy action to the given path.
  # Uses the current +entry+ if no path is given.
  def destroy_action_link(path = nil)
    path ||= path_args(entry)
    action_link(ti('link.delete'), 'remove', path,
                data: { confirm: ti(:confirm_delete),
                        method: :delete })
  end

  # Standard list action to the given path.
  # Uses the current +model_class+ if no path is given.
  def index_action_link(path = nil, url_options = { returning: true })
    path ||= path_args(model_class)
    path = path.is_a?(String) ? path : polymorphic_path(path, url_options)
    action_link(ti('link.list'), 'list', path)
  end

  # Standard add action to given path.
  # Uses the current +model_class+ if no path is given.
  def add_action_link(path = nil, url_options = {})
    path ||= path_args(model_class)
    path = path.is_a?(String) ? path : new_polymorphic_path(path, url_options)
    action_link(ti('link.add'), 'plus', path)
  end

end
