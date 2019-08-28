class Category < ApplicationRecord
  has_and_belongs_to_many :products

  enum category_type: {
    annotation: 'annotation',
    facade: 'facade'
  }

  serializable do
    default do
      attributes :id, :name
    end

    trait :with_postgres_enum do
      attributes :id, :category_type
    end
  end
end
