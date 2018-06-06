module DryCrud
  # Dry Crud Rails engine
  class Engine < Rails::Engine
    initializer 'dry_crud.field_error_proc' do |_app|
      # Fields with errors are directly styled in DryCrud::FormBuilder.
      # Rails should just output the plain html tag.
      ActionView::Base.field_error_proc =
        proc { |html_tag, _instance| html_tag }

      # Load dry_crud engine helpers first so that the application may override
      # them.
      paths = ApplicationController.helpers_path
      helper_path = "#{File::SEPARATOR}app#{File::SEPARATOR}helpers"
      regexp = /dry_crud(-\d+\.\d+\.\d+)?#{helper_path}\z/
      dry_crud_helpers = paths.detect { |p| p =~ regexp }
      if dry_crud_helpers
        paths.delete(dry_crud_helpers)
        paths.prepend(dry_crud_helpers)
      end
    end
  end
end
