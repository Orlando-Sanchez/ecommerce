class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  belongs_to :organization, optional: true
  has_and_belongs_to_many :user_types
  has_many :store_assignments, dependent: :destroy
  has_many :stores, through: :store_assignments
  
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  def self.ransackable_attributes(auth_object = nil)
    %w[id email created_at organization_id]
  end

  def self.ransackable_associations(auth_object = nil)
    ["organization", "user_types"]
  end

  def seller?
    user_types.exists?(name: "Seller")
  end

  def owner?
    user_types.exists?(name: "Owner")
  end
end
