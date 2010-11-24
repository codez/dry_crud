class PeopleController < AjaxController
  
  self.search_columns = [:name, :children, :rating, :income, :birthdate, :remarks]
  
  protected
  
  def list_entries
    super.includes(:city).order('people.name, cities.country_code, cities.name')
  end
  
end