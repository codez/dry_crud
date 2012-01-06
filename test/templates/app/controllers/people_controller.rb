class PeopleController < AjaxController

  self.search_columns = [:name, :children, :rating, :income, :birthdate, :remarks]

  self.sort_mappings = {:city_id => 'cities.name'}

  protected

  def list_entries
    super.includes(:city => :country).order('people.name, countries.code, cities.name')
  end

end