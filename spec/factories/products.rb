FactoryBot.define do
  factory :product do
    name { FFaker::Name.name }
    association :label
    product_type { Product.defined_enums['product_type'].keys.sample }
  end
end
