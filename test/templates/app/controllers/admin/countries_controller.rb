module Admin
  # Countries Controller nested under /admin
  class CountriesController < AjaxController
    self.nesting = :admin

    self.search_columns = :name, :code

    self.default_sort = 'countries.name'

    self.permitted_attrs = %i[name code]

    def show
      redirect_to index_path if request.format.html?
    end
  end
end
