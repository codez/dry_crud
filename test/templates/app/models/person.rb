class Person < ActiveRecord::Base

  alias_attribute :label, :name

  belongs_to :city
  
  validates :name, :presence => true
  
end