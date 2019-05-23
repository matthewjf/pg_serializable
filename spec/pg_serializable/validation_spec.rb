require 'spec_helper'
require 'pry'

RSpec.describe "validation" do
  context "attributes" do
    it "raises error when column is missing" do
      expect do
        class Product < ApplicationRecord
          serializable do
            default do
              attribute :test
            end
          end
        end
      end.to raise_error(PgSerializable::AttributeError)
    end

    it "doesn't raise an error when column exists" do
      expect do
        class Product < ApplicationRecord
          serializable do
            default { attribute :name }
            trait :other do
              attributes :name, :product_type, :label_id
            end
          end
        end
      end.to_not raise_error
    end
  end

  context "associations" do
    it "raises error when association doesn't exist" do
      expect do
        class Product < ApplicationRecord
          serializable do
            default do
              belongs_to :label
            end
          end
        end
      end.to raise_error(PgSerializable::AssociationError)
    end

    it "raises error when cycles exist" do
      expect do
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
      end.to raise_error(PgSerializable::AssociationError)
    end
  end
end
