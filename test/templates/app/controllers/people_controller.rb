class PeopleController < AjaxController

  self.search_columns = [:name, :children, :rating, :income, :birthdate, :remarks, 'cities.name']

  self.default_sort = 'people.name, countries.code, cities.name'

  self.sort_mappings = {:city_id => 'cities.name'}

  self.permitted_attrs = [:name, :children, :city_id, :rating, :income,
                          :birthdate, :gets_up_at, :last_seen, :remarks, :cool]

  private

  def list_entries
    super.includes(:city => :country).
          references(:cities, :countries)
  end

end