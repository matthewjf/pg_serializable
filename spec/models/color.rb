class Color < ApplicationRecord
  has_many :products, through: :variations
  has_many :variations

  serializable do
    default do
      attributes :id, :hex
    end

    trait :has_many_through do
      attribute :id
      has_many :products
    end
  end
end
