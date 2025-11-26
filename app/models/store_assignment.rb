class StoreAssignment < ApplicationRecord
  belongs_to :user
  belongs_to :store

  def self.ransackable_attributes(auth_object = nil)
    %w[id user_id store_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "user", "store" ]
  end
end
