class City < ActiveRecord::Base
  
  has_many :people

  validates_presence_of :name, :country_code
  
  before_destroy :protect_with_inhabitants
  
  default_scope order('country_code, name')
  
  def label
    "#{name} (#{country_code})"
  end
  
  protected
  
  def protect_with_inhabitants
    if people.exists?
      errors.add(:base, "You cannot destroy this city as long as it has any inhabitants") 
      false
    end
  end
  
end