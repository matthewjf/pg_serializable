class Category < ApplicationRecord
  has_and_belongs_to_many :products

  serializable do
    default do
      attributes :id, :name
    end
  end
end
