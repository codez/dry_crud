class Country < ActiveRecord::Base

  has_many :cities

  validates :name, :presence => true
  validates :code, :presence => true

  default_scope order('countries.name')

  def to_s
    name
  end

end