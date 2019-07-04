FactoryBot.define do
  factory :component do
    name { FFaker::Name.name }
  end
end
