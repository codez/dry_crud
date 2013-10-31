# encoding: UTF-8

# Person model
class Person < ActiveRecord::Base

  belongs_to :city

  validates :name, presence: true

  attr_protected nil if Rails.version < '4.0'

  scope :list, -> { order('people.name') }

  def to_s
    name
  end
end