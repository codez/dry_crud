class Country < ActiveRecord::Base

  attr_accessible :name, :code

  has_many :cities, :dependent => :destroy

  validates :name, :presence => true
  validates :code, :presence => true

  default_scope order('countries.name')

  def to_s
    name
  end

end