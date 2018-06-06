# Cities Helper
module CitiesHelper
  def format_city_id(entry)
    city = entry.city
    if city
      link_to(city, admin_country_city_path(city.country, city))
    else
      ta(:no_entry)
    end
  end
end
