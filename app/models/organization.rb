class Organization < ApplicationRecord
  has_many :users
  has_many :stores
  validates :name, presence: true
  validates :description, presence: true

  def self.ransackable_associations(auth_object = nil)
    ["users"]
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id name description created_at updated_at]
  end
end
