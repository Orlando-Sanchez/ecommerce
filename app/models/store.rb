class Store < ApplicationRecord
  belongs_to :organization

  has_many :store_assignments, dependent: :destroy
  has_many :sellers, through: :store_assignments, source: :user

  validates :name, presence: true
  validates :description, presence: true

  def self.ransackable_attributes(auth_object = nil)
    %w[id name description organization_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    ["organization", "store_assignments", "sellers"]
  end
end
