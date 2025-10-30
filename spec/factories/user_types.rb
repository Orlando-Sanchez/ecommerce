FactoryBot.define do
  factory :user_type do
    name { "Owner" }

    trait :seller do
      name { "Seller" }
    end

    trait :buyer do
      name { "Buyer" }
    end
  end
end