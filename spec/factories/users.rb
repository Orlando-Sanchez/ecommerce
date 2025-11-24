FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "User#{n}@gmail.com" }
    password { "password" }
    organization

    trait :owner do
      after(:create) do |user|
        user.user_types << UserType.find_or_create_by!(name: "Owner")
      end
    end

    trait :seller do
      after(:create) do |user|
        user.user_types << UserType.find_or_create_by!(name: "Seller")
      end
    end

    trait :customer do
      after(:create) do |user|
        user.user_types << UserType.find_or_create_by!(name: "Customer")
      end
    end

    trait :without_org do
      organization { nil }
    end
  end
end
