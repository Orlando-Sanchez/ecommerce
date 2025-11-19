FactoryBot.define do
  factory :store_assignment do
    association :user
    association :store
  end
end