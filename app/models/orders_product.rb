class OrdersProduct < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :product_data, presence: true
end