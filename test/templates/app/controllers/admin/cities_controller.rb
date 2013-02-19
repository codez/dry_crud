class Admin::CitiesController < AjaxController

  self.nesting = :admin, Country

  self.search_columns = :name, 'countries.name'

  self.permitted_attrs = [:name, :person_ids]

end