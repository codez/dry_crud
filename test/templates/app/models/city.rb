class City < ActiveRecord::Base

  attr_protected nil

  belongs_to :country
  has_many :people

  validates :name, :presence => true
  validates :country, :presence => true

  before_destroy :protect_with_inhabitants

  default_scope includes(:country).order('countries.code, cities.name')

  def to_s
    "#{name} (#{country.code})"
  end

  protected

  def protect_with_inhabitants
    if people.exists?
      errors.add(:base, :protect_with_inhabitants)
      false
    end
  end

end