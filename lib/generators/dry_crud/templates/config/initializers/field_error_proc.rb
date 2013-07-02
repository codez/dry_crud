# Fields with errors are directly styled in Crud::FormBuilder.
# Rails should just output the plain html tag.
ActionView::Base.field_error_proc = Proc.new {|html_tag, instance| html_tag }