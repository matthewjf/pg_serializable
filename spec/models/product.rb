class Product < ApplicationRecord
  has_and_belongs_to_many :categories
  has_many :variations
  has_many :colors, through: :variations
  belongs_to :label

  enum product_type: {
    color: 0,
    material: 1,
    opening: 2,
  }

  serializable do
    default do
      attributes :name, :id
      has_many :variations
      belongs_to :label
    end

    trait :simple do
      attributes :id
      has_many :variations, trait: :product
    end

    trait :habtm do
      attributes :id, :name
      has_and_belongs_to_many :categories
    end

    trait :with_colors do
      attributes :id, :name
      has_many :colors
    end
  end
end
