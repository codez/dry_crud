# encoding: UTF-8

require 'generators/dry_crud/dry_crud_generator_base'

module DryCrud
  # Copies one file of dry_crud to the rails application.
  class FileGenerator < ::DryCrudGeneratorBase

    argument :filename, type: :string

    def copy_file
      files = matching_files
      case files.size
      when 1
        copy_files(@root_folder => files)
      when 0
        puts "No file containing '#{filename}' found in dry_crud."
      else
        puts "Please be more specific. All the following files match '#{filename}':"
        files.each do |f|
          puts " * #{f}"
        end
      end
    end

    private

    def matching_files
      all_template_files.collect do |root, files|
        files.select do |f| 
          included = f.include?(filename)
          @root_folder = root if included
          included
        end
      end.flatten
    end

  end
end