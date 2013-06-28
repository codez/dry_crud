class Country < ActiveRecord::Base

  has_many :cities, :dependent => :destroy

  validates :name, :presence => true
  validates :code, :presence => true

  attr_protected nil if Rails.version < '4.0'

  def to_s
    name
  end

end