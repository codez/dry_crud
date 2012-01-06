class VipsController < ListController

  self.search_columns = [:name, :children, :rating, :remarks, 'cities.name']

  self.sort_mappings = {:city_id => 'cities.name'}

  protected

  class << self
    def model_class
      Person
    end
  end

  def list_entries
    super.where('rating > 5').includes(:city => :country).order('people.name, countries.code, cities.name')
  end

end