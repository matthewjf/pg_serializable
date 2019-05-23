class Color < ApplicationRecord
  has_many :products, through: :variations
  has_many :variations

  serializable do
    default do
      attributes :id, :hex
    end
  end
end
