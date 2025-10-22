FactoryBot.define do
  factory :order do
    association :user
    association :store
    status { :pending }
  end
end
