module PgSerializable
  module Nodes
    class Association < Base
      attr_reader :klass, :name

      def initialize(klass, name, type, label: nil)
        @name = name
        @klass = klass
        @type = type
        @label = label || name
      end

      def to_sql(outer_alias, aliaser)
        ["\'#{@label}\'", "(#{value(outer_alias, aliaser)})"].join(',')
      end

      def target
        @target ||= association.klass
      end

      private

      def value(outer_alias, aliaser)
        next_alias = aliaser.next!
        self.send(@type, outer_alias, next_alias, aliaser)
      end

      def has_many(outer_alias, next_alias, aliaser)
        return has_many_through(outer_alias, next_alias, aliaser) if association.through_reflection?
        target.as_json_array(aliaser).where("#{next_alias}.#{primary_key}=#{outer_alias}.#{foreign_key}").to_sql
      end

      def has_many_through(outer_alias, next_alias, aliaser)
        through = association.through_reflection
        source = association.source_reflection
        # NOTE: this will fail if the source table shares the same foreign key as your join table
        #       i.e. products and categories have a join table but categories has a product_id column
        association
          .klass
          .select("#{source.table_name}.*, #{through.table_name}.#{source.join_foreign_key}, #{through.table_name}.#{through.join_primary_key}")
          .joins(through.name)
          .as_json_array(aliaser)
          .where("#{next_alias}.#{through.join_primary_key}=#{outer_alias}.#{foreign_key}")
          .to_sql
      end

      def has_one(outer_alias, next_alias, aliaser)
        subquery_alias = "#{next_alias[0]}#{next_alias[1]}#{next_alias[0]}" # avoid alias collision
        target.select("DISTINCT ON (#{primary_key}) #{subquery_alias}.*").from(
          "#{target.table_name} #{subquery_alias}"
        ).as_json_object(aliaser).where("#{next_alias}.#{primary_key}=#{outer_alias}.#{foreign_key}").to_sql
      end

      def belongs_to(outer_alias, next_alias, aliaser)
        target.as_json_object(aliaser).where("#{next_alias}.#{primary_key}=#{outer_alias}.#{foreign_key}").to_sql
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
