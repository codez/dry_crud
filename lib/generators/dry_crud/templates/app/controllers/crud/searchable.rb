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
      if search_support? && params[:q].present?
        search_conditions.reduce(list_entries_without_search) do |query, condition|
          query.where(condition)
        end
      else
        list_entries_without_search
      end
    end

    # Compose the search condition with a basic SQL OR query.
    def search_conditions
      terms = params[:q].split(/\s+/).map { |t| "%#{t}%" }
      terms.collect {|t| search_column_clause(t) }
    end

    # SQL where clause with all search colums or'ed.
    def search_column_clause(term)
      column_conditions = search_columns.collect do |f|
        if f.to_s.include?('.')
          table_name, field_name = f.split('.')
        else
          table_name = model_class.table_name
          field_name = f
        end
        table = Arel::Table.new(table_name)
        table[field_name].matches("%#{term}%")
      end
      column_conditions.reduce do |query, column_condition|
        query.or(column_condition)
      end
    end

    # Returns true if this controller has searchable columns.
    def search_support?
      search_columns.present?
    end

  end
end