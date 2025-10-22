FactoryBot.define do
  factory :store do
    name { Faker::Company.unique.name }
    description { Faker::Company.catch_phrase }
    organization
  end
end