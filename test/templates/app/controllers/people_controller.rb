class PeopleController < AjaxController

  self.search_columns = [:name, :children, :rating, :income, :birthdate, :remarks, 'cities.name']

  self.sort_mappings = {:city_id => 'cities.name'}

  private

  def list_entries
    super.includes(:city => :country).references(:cities, :countries).order('people.name, countries.code, cities.name')
  end

end