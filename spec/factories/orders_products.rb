FactoryBot.define do
  factory :orders_product do
    association :product
    association :order
    unit_price { Faker::Commerce.price(range: 1.0..100.0) }
    product_data { { name: product.name, description: product.description, price: product.price } }
  end
end
