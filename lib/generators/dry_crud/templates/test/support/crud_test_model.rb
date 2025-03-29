# A dummy model used for general testing.
class CrudTestModel < ApplicationRecord # :nodoc:
  belongs_to :companion, class_name: "CrudTestModel", optional: true
  has_and_belongs_to_many :others, class_name: "OtherCrudTestModel"
  has_many :mores, class_name: "OtherCrudTestModel",
                   foreign_key: :more_id

  has_one :comrad, class_name: "CrudTestModel", foreign_key: :companion_id

  before_destroy :protect_if_companion

  validates :name, presence: true
  validates :rating, inclusion: { in: 1..10 }

  def to_s
    name
  end

  def chatty
    remarks.size
  end

  private

  def protect_if_companion
    if companion.present?
      errors.add(:base, "Cannot destroy model with companion")
      throw :abort
    end
  end
end

# Second dummy model to test associations.
class OtherCrudTestModel < ApplicationRecord # :nodoc:
  has_and_belongs_to_many :others, class_name: "CrudTestModel"
  belongs_to :more,
             class_name: "CrudTestModel",
             optional: true

  def to_s
    name
  end
end
