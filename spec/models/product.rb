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
      attributes :id, :name
    end

    trait :custom_sql do
      attribute :active, label: :deleted do |v|
        "NOT #{v}"
      end
    end

    trait :enum do
      attributes :product_type
    end

    trait :custom_attributes do
      attributes :id
      attribute :name, label: :custom_name
    end

    trait :belongs_to do
      attributes :id
      belongs_to :label
    end

    trait :has_many do
      attributes :id
      has_many :variations
    end

    trait :habtm do
      attributes :id
      has_and_belongs_to_many :categories
    end

    trait :has_many_through do
      attributes :id
      has_many :colors
    end

    trait :complex do
      attributes :id, :name
      belongs_to :label
      has_many :variations, trait: :with_color
      has_and_belongs_to_many :categories
    end
  end
end
