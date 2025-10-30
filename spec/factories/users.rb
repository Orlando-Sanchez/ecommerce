FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "User#{n}@gmail.com" }
    password { "password" }
    organization
  end
end
