FactoryBot.define do
  factory :user_type do
    name { "Owner" }

    trait :seller do
      name { "Seller" }
    end

    trait :customer do
      name { "Customer" }
    end
  end
end
