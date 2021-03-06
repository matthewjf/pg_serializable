require 'spec_helper'

RSpec.describe "validation" do
  context "attributes" do
    it "raises error when column is missing" do
      class Product < ApplicationRecord
        serializable do
          default do
            attribute :test
          end
        end
      end

      expect { PgSerializable.validate_traits! }.to raise_error(PgSerializable::AttributeError)
    end

    it "doesn't raise an error when column exists" do
      class Product < ApplicationRecord
        serializable do
          default { attribute :name }
          trait :other do
            attributes :name, :product_type, :label_id
          end
        end
      end

      expect { PgSerializable.validate_traits! }.to_not raise_error
    end
  end

  context "associations" do
    it "raises error when association doesn't exist" do
      class Product < ApplicationRecord
        serializable do
          default do
            belongs_to :nonexistant
          end
        end
      end

      expect { PgSerializable.validate_traits! }.to raise_error(PgSerializable::AssociationError)
    end

    it "raises error when cycles exist" do
      class Label < ApplicationRecord
        has_many :products
        serializable do
          default do
            has_many :products
          end
        end
      end
      class Product < ApplicationRecord
        belongs_to :label
        serializable do
          default do
            belongs_to :label
          end
        end
      end

      expect { PgSerializable.validate_traits! }.to raise_error(PgSerializable::AssociationError)
    end
  end
end
