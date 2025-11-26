class Product < ApplicationRecord
  has_and_belongs_to_many :categories
  belongs_to :store, optional: true
  belongs_to :user, optional: true

  validates :name, presence: true
  validates :description, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true

  enum :status, { available: 0, out_of_stock: 1, discontinued: 2, unavailable: 3 }

  STATUS_LABELS = {
    "Available" => "Available",
    "Out_of_stock" => "Out of stock",
    "Discontinued" => "Discontinued",
    "Unavailable" => "Unavailable"
  }.freeze

  def readable_status
    STATUS_LABELS[status]
  end
end
