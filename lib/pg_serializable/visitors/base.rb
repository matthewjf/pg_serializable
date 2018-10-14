module PgSerializable
  module Visitors
    class Base
      def visit(subject, **kwargs)
        send(visit_method_for(subject), subject, **kwargs)
      end

      def visit_method_for(subject)
        case subject
        when record? then :visit_record
        when class? then :visit_class
        when relation? then :visit_relation
        when trait_manager? then :visit_trait_manager
        when trait? then :visit_trait
        when node? then :visit_node
        else :visit_other
        end
      end

      # activerecord

      def visit_record(subject, **kwargs)
        raise NotImplementedError.new
      end

      def visit_class(subject, **kwargs)
        raise NotImplementedError.new
      end

      def visit_scope(subject, **kwargs)
        raise NotImplementedError.new
      end

      # pg_serializable

      def visit_trait_manager(subject, **kwargs)
        raise NotImplementedError.new
      end

      def visit_trait(subject, **kwargs)
        raise NotImplementedError.new
      end

      def visit_node(subject, **kwargs)
        raise NotImplementedError.new
      end

      # everything else

      def visit_other(subject, **kwargs)
        raise NotImplementedError.new
      end

      private

      def record?
        ->(x) { x.is_a? ApplicationRecord }
      end

      def class?
        ->(x) { x.is_a? Class }
      end

      def relation?
        ->(x) { x.is_a? ActiveRecord::Relation }
      end

      def trait_manager?
        ->(x) { x.is_a? PgSerializable::TraitManager }
      end

      def trait?
        ->(x) { x.is_a? PgSerializable::Trait }
      end

      def node?
        ->(x) { x.is_a? PgSerializable::Nodes::Base }
      end

      def attribute?
        ->(x) { x.is_a? PgSerializable::Nodes::Attribute }
      end

      def association?
        ->(x) { x.is_a? PgSerializable::Nodes::Association }
      end
    end
  end
end
