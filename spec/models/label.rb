class Label < ApplicationRecord
  has_many :products

  serializable do
    default do
      attributes :name, :id
    end

    trait :simple do
      attributes :name
    end
  end
end
