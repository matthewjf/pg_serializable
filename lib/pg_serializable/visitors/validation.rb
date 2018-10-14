module PgSerializable
  module Visitors
    class Validation < Base
      def visit_class(subject, **kwargs)
        visit subject.trait_manager
      end

      def visit_trait_manager(subject, **kwargs)
        subject.traits.each do |_, value|
          visit value
        end
      end

      def visit_trait(subject, **kwargs)
        subject.attribute_nodes.each { |attribute_node| visit attribute_node }
        ensure_no_cycles!(subject)
      end

      def visit_node(subject, **kwargs)
        if subject.is_a? PgSerializable::Nodes::Attribute
          visit_attribute_node(subject, **kwargs)
        elsif subject.is_a? PgSerializable::Nodes::Association
          visit_association_node(subject, **kwargs)
        else
          raise UnknownAttributeError.new('validation visitor called with unknow node type')
        end
      end

      def visit_attribute_node(subject, **kwargs)
        klass = subject.klass
        column_name = subject.column_name
        unless klass.column_names.include? column_name.to_s
          raise PgSerializable::AttributeError.new("column `#{column_name}` doesn't exist for class #{klass}")
        end
      end

      def visit_association_node(subject, **kwargs)
        klass = subject.klass
        name = subject.name
        if klass.reflect_on_association(name).nil?
          raise PgSerializable::AssociationError.new("association `#{name.to_s}` doesn't exist for class #{klass}")
        end
        if subject.target.trait_manager.get_trait(subject.trait).nil?
          raise PgSerializable::AssociationError.new("trait `#{subect.trait}` doesn't exist for class #{subject.target}")
        end
      end

      private

      def ensure_no_cycles!(trait)
        @root_klass = trait.klass
        check_for_cycles(trait)
      end

      def check_for_cycles(subject)
        case subject
        when trait? then subject.attribute_nodes.each { |node| check_for_cycles(node) }
        when association?
          if subject.target == @root_klass
            raise PgSerializable::AssociationError.new("class #{@root_klass} contains a cycle in nested association #{subject.klass}")
          end
          associated_trait = subject.target.trait_manager.get_trait subject.trait
          check_for_cycles(associated_trait)
        end
      end
    end
  end
end
