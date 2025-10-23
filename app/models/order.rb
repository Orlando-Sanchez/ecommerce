class Order < ApplicationRecord
  belongs_to :user
  belongs_to :store

  validates :status, presence: true

  enum :status, { pending: 0, completed: 1, canceled: 2 }
end
