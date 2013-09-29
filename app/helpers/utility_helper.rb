# encoding: UTF-8

# View helpers for basic functions used in various other helpers.
module UtilityHelper

  EMPTY_STRING = '&nbsp;'.html_safe   # non-breaking space asserts better css.

  # Render a content tag with the collected contents rendered
  # by &block for each item in collection.
  def content_tag_nested(tag, collection, options = {}, &block)
    content_tag(tag, safe_join(collection, &block), options)
  end

  # Overridden method that takes a block that is executed for each item in
  # array before appending the results.
  def safe_join(array, sep = $OUTPUT_FIELD_SEPARATOR, &block)
    super(block_given? ? array.map(&block).compact : array, sep)
  end

  # Returns the css class for the given flash level.
  def flash_class(level)
    case level
    when :notice then 'success'
    when :alert then 'error'
    else level.to_s
    end
  end

  # Adds a class to the given options, even if there are already classes.
  def add_css_class(options, classes)
    if options[:class]
      options[:class] += ' ' + classes if classes
    else
      options[:class] = classes
    end
  end

  # The default attributes to use in attrs, list and form partials.
  # These are all defined attributes except certain special ones like
  # 'id' or 'position'.
  def default_crud_attrs
    attrs = model_class.column_names.map(&:to_sym)
    attrs - [:id, :position, :password]
  end

  # Returns the ActiveRecord column type or nil.
  def column_type(obj, attr)
    column_property(obj, attr, :type)
  end

  # Returns an ActiveRecord column property for the passed attr or nil
  def column_property(obj, attr, property)
    if obj.respond_to?(:column_for_attribute)
      column = obj.column_for_attribute(attr)
      column.try(property)
    end
  end

  # Returns the association proxy for the given attribute. The attr parameter
  # may be the _id column or the association name. If a macro (e.g.
  # :belongs_to) is given, the association must be of this type, otherwise,
  # any association is returned. Returns nil if no association (or not of the
  # given macro) was found.
  def association(obj, attr, *macros)
    if obj.class.respond_to?(:reflect_on_association)
      name = assoc_and_id_attr(attr).first.to_sym
      assoc = obj.class.reflect_on_association(name)
      assoc if assoc && (macros.blank? || macros.include?(assoc.macro))
    end
  end

  # Returns the name of the attr and it's corresponding field
  def assoc_and_id_attr(attr)
    attr = attr.to_s
    if attr.end_with?('_id')
      [attr[0..-4], attr]
    elsif attr.end_with?('_ids')
      [attr[0..-5].pluralize, attr]
    else
      [attr, "#{attr}_id"]
    end
  end

end
