module PeopleHelper
  
  def format_income(person)
    "#{f(person.income)} $"
  end
  
end