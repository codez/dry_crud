module CitiesHelper
  def format_city_id(entry)
    if city = entry.city
      link_to city, admin_country_city_path(city.country, city)
    else
      ta(:no_entry)
    end
  end
end