class Variation < ApplicationRecord
  belongs_to :product
  belongs_to :color

  serializable do
    default do
      attributes :name, :id
    end

    trait :with_color do
      attributes :id, :name
      belongs_to :color
    end
  end
end
