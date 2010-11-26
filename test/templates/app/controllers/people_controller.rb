class PeopleController < AjaxController
  
  self.search_columns = [:name, :children, :rating, :income, :birthdate, :remarks]
  self.sort_mappings = {:city_id => 'cities.name'}
  
  protected
  
  def list_entries
    super.includes(:city).order('people.name, cities.country_code, cities.name')
  end
  
end