module PgSerializable
  class Trait
    attr_reader :klass, :attribute_nodes

    def initialize(klass)
      @klass = klass
      @attribute_nodes = []
    end

    def attributes(*attrs)
      attrs.each do |attribute|
        @attribute_nodes << Nodes::Attribute.new(klass, attribute)
      end
    end

    def attribute(column_name, label: nil, &blk)
      @attribute_nodes << Nodes::Attribute.new(klass, column_name, label: label, &blk)
    end

    def has_many(association, label: nil, trait: :default)
      @attribute_nodes << Nodes::Association.new(klass, association, :has_many, label: label, trait: trait)
    end

    def belongs_to(association, label: nil, trait: :default)
      @attribute_nodes << Nodes::Association.new(klass, association, :belongs_to, label: label, trait: trait)
    end

    def has_one(association, label: nil, trait: :default)
      @attribute_nodes << Nodes::Association.new(klass, association, :has_one, label: label, trait: trait)
    end

    def has_and_belongs_to_many(association, label: nil, trait: :default)
      @attribute_nodes << Nodes::Association.new(klass, association, :has_and_belongs_to_many, label: label, trait: trait)
    end
  end
end
