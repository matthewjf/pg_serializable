class MaterialComponent < Component
  serializable do
    default do
      attributes :id, :name
    end
  end
end
