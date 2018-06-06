# Person model
class Person < ApplicationRecord
  belongs_to :city

  validates :name, presence: true

  scope :list, -> { order('people.name') }

  def to_s
    name
  end
end
