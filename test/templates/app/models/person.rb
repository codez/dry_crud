class Person < ActiveRecord::Base

  belongs_to :city

  validates :name, :presence => true

  def to_s
    name
  end
end