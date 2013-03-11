class Country < ActiveRecord::Base

  has_many :cities, :dependent => :destroy

  validates :name, :presence => true
  validates :code, :presence => true

  def to_s
    name
  end

end