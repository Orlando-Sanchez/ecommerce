class Store < ApplicationRecord
  belongs_to :organization

  has_many :store_assignments, dependent: :destroy
  has_many :sellers, through: :store_assignments, source: :user

  validates :name, presence: true
  validates :description, presence: true
end
