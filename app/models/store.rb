class Store < ApplicationRecord
  belongs_to :organization

  validates :name, presence: true
  validates :description, presence: true
end
