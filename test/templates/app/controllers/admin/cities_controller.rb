class Admin::CitiesController < AjaxController

  self.nesting = :admin, Country

  self.search_columns = :name, 'countries.name'

  self.permitted_attrs = [:name, :person_ids]

  self.default_sort = 'countries.code, cities.name'


  private

  def list_entries
    super.includes(:country).references(:countries)
  end

end