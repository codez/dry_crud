begin
  require 'generators/dry_crud/dry_crud_generator_base'
rescue LoadError => _ # rubocop:disable Lint/HandleExceptions
  # ok, we are in the rake task
end

# Copies all dry_crud files to the rails application.
class DryCrudGenerator < DryCrudGeneratorBase
  desc 'Copy all dry_crud files to the application.'

  class_options %w[templates -t] => 'erb'
  class_options %w[tests] => 'testunit'

  # copy everything to application
  def install_dry_crud
    copy_files(all_template_files)

    Dir.chdir(self.class.template_root) do
      copy_crud_test_model
    end

    readme 'INSTALL'
  end

  private

  def should_copy?(file_source)
    !file_source.end_with?(exclude_template) &&
      !file_source.start_with?(exclude_test_dir) &&
      file_source != 'INSTALL'
  end

  def copy_crud_test_model
    unless exclude_test_dir == 'spec'
      template(File.join('test', 'support', 'crud_test_model.rb'),
               File.join('spec', 'support', 'crud_test_model.rb'))
      template(File.join('test', 'support', 'crud_test_models_controller.rb'),
               File.join('spec', 'support', 'crud_test_models_controller.rb'))
      template(File.join('test', 'support', 'crud_test_helper.rb'),
               File.join('spec', 'support', 'crud_test_helper.rb'))
    end
  end

  def exclude_template
    options[:templates].casecmp('haml').zero? ? '.erb' : '.haml'
  end

  def exclude_test_dir
    case options[:tests].downcase
    when 'rspec' then 'test'
    when 'all' then 'exclude_nothing'
    else 'spec'
    end
  end
end
