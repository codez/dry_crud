class VipsController < ListController

  self.search_columns = [:name, :children, :rating, :remarks]

  self.sort_mappings = {:city_id => 'cities.name'}

  def index
    @title = 'Listing VIPs'
    super
  end

  protected

  class << self
    def model_class
      Person
    end
  end

  def list_entries
    super.where('rating > 5').includes(:city).order('people.name, cities.country_code, cities.name')
  end

end