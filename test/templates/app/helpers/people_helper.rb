module PeopleHelper

  def format_person_income(person)
    income = person.income
    income.present? ? "#{f(income)} $" : StandardHelper::EMPTY_STRING
  end

end