# encoding: UTF-8

module DryCrud
  # The search functionality for the index table.
  # Define an array of searchable string columns in your subclassing
  # controllers using the class attribute +search_columns+.
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
      list_entries_without_search.where(search_conditions)
    end

    # Concat the word clauses with AND.
    def search_conditions
      if search_support? && params[:q].present?
        search_word_conditions.reduce do |query, condition|
          query.and(condition)
        end
      end
    end

    # Split the search query in single words and create a list of word clauses.
    def search_word_conditions
      params[:q].split(/\s+/).map { |w| search_word_condition(w) }
    end

    # Concat the column queries of the given word with OR.
    def search_word_condition(word)
      search_column_condition(word).reduce do |query, condition|
        query.or(condition)
      end
    end

    # Create a list of Arel #matches queries for each column and the given
    # word.
    def search_column_condition(word)
      self.class.search_tables_and_fields.map do |table_name, field|
        table = Arel::Table.new(table_name)
        table[field].matches("%#{word}%")
      end
    end

    # Returns true if this controller has searchable columns.
    def search_support?
      search_columns.present?
    end

    # Class methods for Searchable.
    module ClassMethods

      # All search columns divided in table and field names.
      def search_tables_and_fields
        @search_tables_and_fields ||= search_columns.map do |f|
          if f.to_s.include?('.')
            f.split('.', 2)
          else
            [model_class.table_name, f]
          end
        end
      end
    end

  end
end
