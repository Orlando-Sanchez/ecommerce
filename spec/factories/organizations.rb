FactoryBot.define do
  factory :organization do
    name { Faker::Company.unique.name }
    description { Faker::Company.catch_phrase }
  end
end
