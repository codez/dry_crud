module Admin
  # Cities Controller nested under /admin and countries
  class CitiesController < AjaxController
    self.nesting = :admin, Country

    self.search_columns = :name, 'countries.name'

    self.default_sort = 'countries.code, cities.name'

    self.permitted_attrs = %i[name person_ids]

    private

    def list_entries
      list = super.includes(:country)
      list = list.references(:countries) if list.respond_to?(:references)
      list
    end
  end
end
