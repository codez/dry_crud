module DryCrud
  class Engine < Rails::Engine
    initializer "dry_crud.field_error_proc" do |app|
      # Fields with errors are directly styled in Crud::FormBuilder.
      # Rails should just output the plain html tag.
      ActionView::Base.field_error_proc = proc { |html_tag, instance| html_tag }
    end
  end
end