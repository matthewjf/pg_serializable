class Product < ApplicationRecord
  # has_many :categories_products
  # has_many :categories, through: :categories_products
  has_and_belongs_to_many :categories
  has_many :variations
  belongs_to :label
  enum product_type: {
    color: 0,
    material: 1,
    opening: 2,
  }

  serializable do
    default do
      attributes :name, :id
      # attribute :name, label: :test_name
      has_many :variations
      belongs_to :label
      # has_many :categories
    end

    trait :simple do
      attributes :id
      has_many :variations, trait: :product
    end

    trait :habtm do
      attributes :id, :name
      # has_many :categories
      has_and_belongs_to_many :categories
    end
  end
end
