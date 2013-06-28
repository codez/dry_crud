class Admin::CitiesController < AjaxController

  self.nesting = :admin, Country

  self.search_columns = :name, 'countries.name'

  self.permitted_attrs = [:name, :person_ids]

  self.default_sort = 'countries.code, cities.name'


  private

  def list_entries
    list = super.includes(:country)
    list = list.references(:countries) if list.respond_to?(:references)
    list
  end

end