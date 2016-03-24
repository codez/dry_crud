# encoding: UTF-8

# City model
class City < ActiveRecord::Base
  belongs_to :country
  has_many :people

  validates :name, presence: true
  validates :country, presence: true

  before_destroy :protect_with_inhabitants

  scope :options_list, -> { includes(:country).order('cities.name') }

  def to_s
    "#{name} (#{country.code})"
  end

  private

  def protect_with_inhabitants
    if people.exists?
      errors.add(:base, :protect_with_inhabitants)
      throw :abort
    end
  end
end
