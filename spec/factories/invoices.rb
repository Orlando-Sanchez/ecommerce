FactoryBot.define do
  factory :invoice do
    association :store
    association :order
    status { :pending }
  end
end
