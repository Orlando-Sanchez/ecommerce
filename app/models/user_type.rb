class UserType < ApplicationRecord
    validates :name, presence: true, uniqueness: true
end
