# encoding: UTF-8

module Crud
  # The search functionality for the index table.
  # Define an array of searchable columns in your subclassing controllers
  # using the class attribute +search_columns+.
  module Searchable
    extend ActiveSupport::Concern

    included do
      class_attribute :search_columns
      self.search_columns = []

      helper_method :search_support?

      alias_method_chain :list_entries, :search
    end

    private

    # Enhance the list entries with an optional search criteria
    def list_entries_with_search
      list_entries_without_search.where(search_condition)
    end

    # Compose the search condition with a basic SQL OR query.
    def search_condition
      if search_support? && params[:q].present?
        col_clause = search_column_clause
        terms = params[:q].split(/\s+/).map { |t| "%#{t}%" }
        term_clause = terms.map { |t| "(#{col_clause})" }.join(' AND ')

        term_params = terms.map { |t| [t] * search_columns.size }.flatten
        ["(#{term_clause})", *term_params]
      end
    end

    # SQL where clause with all search colums or'ed.
    def search_column_clause
      search_columns.map do |f|
        if f.to_s.include?('.')
          "#{f} LIKE ?"
        else
          "#{model_class.table_name}.#{f} LIKE ?"
        end
      end.join(' OR ')
    end

    # Returns true if this controller has searchable columns.
    def search_support?
      search_columns.present?
    end

  end
end