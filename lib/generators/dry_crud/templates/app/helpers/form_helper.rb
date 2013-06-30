# Defines forms to edit models. The helper methods come in different granularities:
# * <tt>#standard_form</tt> - Form using Crud::FormBuilder.
# * <tt>#crud_form</tt> - standard_form for a given entry and attributes with error messages and save and cancel buttons.
# * <tt>#entry_form</tt> - crud_form for the current #entry, with the given attributes or default.
module FormHelper

  # Renders a form using Crud::FormBuilder.
  def standard_form(object, options = {}, &block)
    options[:html] ||= {}
    add_css_class(options[:html], 'form-horizontal')
    options[:builder] ||= Crud::FormBuilder
    options[:cancel_url] ||= polymorphic_path(object, :returning => true)

    form_for(object, options, &block)
  end

  # Renders a standard form for the given entry and attributes.
  # The form is rendered with a basic save and cancel button.
  # If a block is given, custom input fields may be rendered and attrs is ignored.
  # Before the input fields, the error messages are rendered, if present.
  # An options hash may be given as the last argument.
  def crud_form(object, *attrs, &block)
    standard_form(object, attrs.extract_options!) do |form|
      content = form.error_messages

      if block_given?
        content << capture(form, &block)
      else
        content << form.labeled_input_fields(*attrs)
      end

      content << form.standard_actions
      content.html_safe
    end
  end

  # Renders a crud form for the current entry with default_crud_attrs or the
  # given attribute array. An options hash may be given as the last argument.
  # If a block is given, a custom form may be rendered and attrs is ignored.
  def entry_form(*attrs, &block)
    options = attrs.extract_options!
    attrs = default_crud_attrs - [:created_at, :updated_at] if attrs.blank?
    attrs << options
    crud_form(path_args(entry), *attrs, &block)
  end

end