class Admin::CitiesController < AjaxController

  self.nesting = :admin, Country

  self.search_columns = :name, 'countries.name'

end