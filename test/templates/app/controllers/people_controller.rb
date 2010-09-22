class PeopleController < AjaxController
  
  self.search_columns = [:name, :children, :rating, :income, :birthdate, :remarks]
  
  protected
  
  def fetch_all_options
    {:include => :city, :order => 'people.name, cities.country_code, cities.name'}
  end
  
end