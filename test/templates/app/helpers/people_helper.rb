# encoding: UTF-8

# People Helper
module PeopleHelper

  def format_person_income(person)
    income = person.income
    income.present? ? "#{f(income)} $" : UtilityHelper::EMPTY_STRING
  end

end