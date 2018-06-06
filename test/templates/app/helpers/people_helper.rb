# People Helper
module PeopleHelper
  def format_person_income(person)
    income = person.income
    income.present? ? "#{f(income)} $" : UtilityHelper::EMPTY_STRING
  end

  def f(value)
    case value
    when true then 'iu'
    else super(value)
    end
  end
end
