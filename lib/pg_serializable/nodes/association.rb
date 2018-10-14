module PgSerializable
  module Nodes
    class Association < Base
      attr_reader :klass, :name, :trait, :type, :label

      def initialize(klass, name, type, label: nil, trait: :default)
        @name = name
        @klass = klass
        @type = type
        @label = label || name
        @trait = trait
      end

      def to_sql(outer_alias, aliaser)
        ["\'#{@label}\'", "(#{value(outer_alias, aliaser)})"].join(',')
      end

      def target
        @target ||= association.klass
      end

      def association
        @association ||= @klass.reflect_on_association(@name)
      end

      def foreign_key
        @foreign_key ||= association.join_foreign_key
      end

      def primary_key
        @primary_key ||= association.join_primary_key
      end
    end
  end
end
