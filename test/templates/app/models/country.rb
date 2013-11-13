# encoding: UTF-8

# Country model
class Country < ActiveRecord::Base

  has_many :cities, dependent: :destroy

  validates :name, :code, presence: true, uniqueness: true

  attr_protected nil if Rails.version < '4.0'

  def to_s
    name
  end

end
