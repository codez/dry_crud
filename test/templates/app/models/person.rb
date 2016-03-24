# encoding: UTF-8

# Person model
class Person < ActiveRecord::Base
  belongs_to :city

  validates :name, presence: true

  scope :list, -> { order('people.name') }

  def to_s
    name
  end
end
