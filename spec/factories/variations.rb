FactoryBot.define do
  factory :variation do
    name { FFaker::Name.name }
    association :product
    association :color
  end
end
