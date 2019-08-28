FactoryBot.define do
  factory :category do
    name { FFaker::Name.name }
    category_type { Category.category_types.keys.sample }
  end
end
