class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  belongs_to :organization, optional: true
  has_and_belongs_to_many :user_types
  has_many :store_assignments, dependent: :destroy
  has_many :stores, through: :store_assignments
  has_many :products, dependent: :nullify

  validates :email, presence: true, uniqueness: { case_sensitive: false }

  def self.ransackable_attributes(auth_object = nil)
    %w[id email created_at organization_id]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "organization", "user_types" ]
  end

  def seller?
    user_types.exists?(name: "Seller")
  end

  def owner?
    user_types.exists?(name: "Owner")
  end

  def customer?
    user_types.exists?(name: "Customer")
  end

  # Enforce role exclusivity rules:
  # - Owners must not have the Customer role.
  # - Sellers who belong to an organization must not have the Customer role.
  # - Sellers without an organization may also be Customers.
  # We normalize after commit so tests/factories can set roles freely and
  # we clean up any disallowed combinations consistently.
  after_commit :normalize_user_types, on: [ :create, :update ]

  private

  def normalize_user_types
    # Ensure we have the latest association values
    user_types.reload

    # If the user is an Owner, always remove Customer role
    if user_types.exists?(name: "Owner")
      user_types.where(name: "Customer").destroy_all
    end

    # If the user is a Seller and belongs to an organization, remove Customer
    if user_types.exists?(name: "Seller") && organization.present?
      user_types.where(name: "Customer").destroy_all
    end
  end
end
