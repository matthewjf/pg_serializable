class Variation < ApplicationRecord
  belongs_to :product
  belongs_to :color

  serializable do
    default do
      attributes :name, :id
      belongs_to :color
    end

    trait :product do
      attributes :id
    end
  end
end
