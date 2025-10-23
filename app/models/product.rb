class Product < ApplicationRecord
  has_and_belongs_to_many :categories
  belongs_to :store

  validates :name, presence: true
  validates :description, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true

  enum :status, { active: 0, inactive: 1 }
end
