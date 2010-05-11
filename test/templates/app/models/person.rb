class Person < ActiveRecord::Base

  alias_attribute :label, :name

  belongs_to :city
  
  validates_presence_of :name
  
end