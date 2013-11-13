# encoding: UTF-8

# Provides uniform formatting of basic data types, based on Ruby class (#f)
# or database column type (#format_attr). If other helpers define methods
# with names like 'format_{class}_{attr}', these methods are used for
# formatting.
#
# Futher helpers standartize the layout of multiple attributes (#render_attrs),
# values with labels (#labeled) and simple lists.
module FormatHelper

  # Formats a basic value based on its Ruby class.
  def f(value)
    case value
    when Float, BigDecimal then
      number_with_precision(value, precision: t('number.format.precision'),
                                   delimiter: t('number.format.delimiter'))
    when Date   then l(value)
    when Time   then "#{l(value.to_date)} #{l(value, format: :time)}"
    when true   then t('global.yes')
    when false  then t('global.no')
    when nil    then UtilityHelper::EMPTY_STRING
    else value.to_s
    end
  end

  # Formats an arbitrary attribute of the given ActiveRecord object.
  # If no specific format_{class}_{attr} or format_{attr} method is found,
  # formats the value as follows:
  # If the value is an associated model, renders the label of this object.
  # Otherwise, calls format_type.
  def format_attr(obj, attr)
    format_with_helper(obj, attr) ||
    format_association(obj, attr) ||
    format_type(obj, attr)
  end

  # Renders a simple unordered list, which will
  # simply render all passed items or yield them
  # to your block.
  def simple_list(items, ul_options = {}, &block)
    content_tag_nested(:ul, items, ul_options) do |item|
      content_tag(:li, block_given? ? yield(item) : f(item))
    end
  end

  # Renders a list of attributes with label and value for a given object.
  # Optionally surrounded with a div.
  def render_attrs(obj, *attrs)
    content_tag_nested(:dl, attrs, class: 'dl-horizontal') do |a|
      labeled_attr(obj, a)
    end
  end

  # Renders the formatted content of the given attribute with a label.
  def labeled_attr(obj, attr)
    labeled(captionize(attr, obj.class), format_attr(obj, attr))
  end

  # Renders an arbitrary content with the given label. Used for uniform
  # presentation.
  def labeled(label, content = nil, &block)
    content = capture(&block) if block_given?
    render('shared/labeled', label: label, content: content)
  end

  # Transform the given text into a form as used by labels or table headers.
  def captionize(text, clazz = nil)
    text = text.to_s
    if clazz.respond_to?(:human_attribute_name)
      text_without_id = text.end_with?('_ids') ? text[0..-5].pluralize : text
      clazz.human_attribute_name(text_without_id)
    else
      text.humanize.titleize
    end
  end

  private

  # Checks whether a format_{class}_{attr} or format_{attr} helper method is
  # defined and calls it if is.
  def format_with_helper(obj, attr)
    class_name = obj.class.name.underscore.gsub('/', '_')
    format_type_attr_method = :"format_#{class_name}_#{attr}"
    format_attr_method = :"format_#{attr}"

    if respond_to?(format_type_attr_method)
      send(format_type_attr_method, obj)
    elsif respond_to?(format_attr_method)
      send(format_attr_method, obj)
    else
      false
    end
  end

  # Checks whether the given attr is an association of obj and formats it
  # accordingly if it is.
  def format_association(obj, attr)
    belongs_to = association(obj, attr, :belongs_to)
    has_many = association(obj, attr, :has_many, :has_and_belongs_to_many)
    if belongs_to
      format_belongs_to(obj, belongs_to)
    elsif has_many
      format_has_many(obj, has_many)
    else
      false
    end
  end

  # Formats an arbitrary attribute of the given object depending on its data
  # type. For Active Records, take the defined data type into account for
  # special types that have no own object class.
  def format_type(obj, attr)
    val = obj.send(attr)
    return UtilityHelper::EMPTY_STRING if val.blank? && val != false

    case column_type(obj, attr)
    when :time    then l(val, format: :time)
    when :date    then f(val.to_date)
    when :datetime, :timestamp then f(val.time)
    when :text    then simple_format(h(val))
    when :decimal then
      number_with_precision(val.to_s.to_f,
                            precision: column_property(obj, attr, :scale),
                            delimiter: t('number.format.delimiter'))
    else f(val)
    end
  end

  # Formats an ActiveRecord +belongs_to+ association
  def format_belongs_to(obj, assoc)
    val = obj.send(assoc.name)
    if val
      assoc_link(assoc, val)
    else
      ta(:no_entry, assoc)
    end
  end

  # Formats an ActiveRecord +has_and_belongs_to_many+ or
  # +has_many+ association.
  def format_has_many(obj, assoc)
    values = obj.send(assoc.name)
    if values.size == 1
      assoc_link(assoc, values.first)
    elsif values.present?
      simple_list(values) { |val| assoc_link(assoc, val) }
    else
      ta(:no_entry, assoc)
    end
  end

  # Renders a link to the given association entry.
  def assoc_link(assoc, val)
    link_to_if(assoc_link?(assoc, val), val.to_s, val)
  end

  # Returns true if no link should be created when formatting the given
  # association.
  def assoc_link?(assoc, val)
    respond_to?("#{val.class.model_name.singular_route_key}_path".to_sym)
  end

end
