class City < ActiveRecord::Base
  
  has_many :people

  validates_presence_of :name, :country_code
  
  default_scope order('country_code, name')
  
  def label
    "#{name} (#{country_code})"
  end
  
end