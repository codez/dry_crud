class Person < ActiveRecord::Base

  attr_protected nil

  belongs_to :city

  validates :name, :presence => true

  def to_s
    name
  end
end