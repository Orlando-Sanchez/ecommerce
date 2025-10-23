class Invoice < ApplicationRecord
  belongs_to :store
  belongs_to :order

  enum :status, { pending: 0, paid: 1, cancelled: 2 }

  validates :status, presence: true
end
