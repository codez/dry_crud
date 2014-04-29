# encoding: UTF-8

module Admin
  # Countries Controller nested under /admin
  class CountriesController < AjaxController

    self.nesting = :admin

    self.search_columns = :name, :code

    self.default_sort = 'countries.name'

    self.permitted_attrs = [:name, :code] if respond_to?(:permitted_attrs)

    def show
      super do |format|
        format.html { redirect_to index_url, flash.to_hash }
      end
    end

  end
end
