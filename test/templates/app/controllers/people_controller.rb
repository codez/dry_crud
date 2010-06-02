class PeopleController < AjaxController
  
  def fetch_all_options
    {:include => :city, :order => 'people.name, cities.country_code, cities.name'}
  end
  
end