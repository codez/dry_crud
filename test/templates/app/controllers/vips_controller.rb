class VipsController < ListController

  self.search_columns = [:name, :children, :rating, :remarks, 'cities.name']

  self.sort_mappings = {:city_id => 'cities.name'}

  self.default_sort = 'people.name, countries.code, cities.name'

  private

  class << self
    def model_class
      Person
    end
  end

  def list_entries
    super.where('rating > 5').
          includes(:city => :country).
          references(:cities, :countries)
  end

end