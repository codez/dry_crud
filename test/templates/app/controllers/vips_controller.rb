# encoding: UTF-8

# List Controller for VIP people
class VipsController < ListController

  self.search_columns = [:name, :children, :rating, :remarks, 'cities.name']

  self.sort_mappings = { city_id: 'cities.name' }

  self.default_sort = 'people.name, countries.code, cities.name'

  private

  class << self
    def model_class
      Person
    end
  end

  def list_entries
    list = super.where('rating > 5').includes(city: :country)
    if list.respond_to?(:references)
      list = list.references(:cities, :countries)
    end
    list
  end

end