# People Controller
class PeopleController < TurboController
  self.search_columns = [ :name, :email, :remarks, "cities.name" ]

  self.default_sort = "people.name, countries.code, cities.name"

  self.sort_mappings = { city_id: "cities.name" }

  self.permitted_attrs = %i[name children city_id rating income
                            birthdate gets_up_at last_seen remarks
                            cool email password]

  private

  def list_entries
    list = super.includes(city: :country)
    if list.respond_to?(:references)
      list = list.references(:cities, :countries)
    end
    list
  end
end
