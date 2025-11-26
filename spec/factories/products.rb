FactoryBot.define do
  factory :product do
    association :store
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph }
    quantity { 10 }
    price { 10.50 }
    status { :available }
  end
end
