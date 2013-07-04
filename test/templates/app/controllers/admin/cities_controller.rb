# encoding: UTF-8

# Cities Controller nested under /admin and countries
class Admin::CitiesController < AjaxController

  self.nesting = :admin, Country

  self.search_columns = :name, 'countries.name'

  self.default_sort = 'countries.code, cities.name'

  self.permitted_attrs = [:name, :person_ids] if respond_to?(:permitted_attrs)

  private

  def list_entries
    list = super.includes(:country)
    list = list.references(:countries) if list.respond_to?(:references)
    list
  end

end