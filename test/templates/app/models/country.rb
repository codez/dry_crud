# Country model
class Country < ApplicationRecord
  has_many :cities, dependent: :destroy

  validates :name, :code, presence: true, uniqueness: true

  def to_s
    name
  end
end
