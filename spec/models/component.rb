class Component < ApplicationRecord
  serializable do
    default do
      attributes :id, :name, :type
    end
  end
end
