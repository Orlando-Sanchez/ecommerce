FactoryBot.define do
  factory :user_type do
    sequence(:name) { |n| "UserType#{n}" }    
  end
end