module PgSerializable
  module Visitors
    class Json < Base
      def visit_record(subject, trait: :default)
        table_alias = next_alias!

        klass = subject.class
        base_class = klass.base_class
        select_sql = json_build_object(visit(klass.trait_manager, trait: trait, table_alias: table_alias)).to_sql
        from_sql = base_class.where(id: subject.id).limit(1).to_sql

        base_class.select(select_sql).from("#{as(from_sql, table_alias)}")
      end

      def visit_relation(subject, table_alias: nil, trait: :default)
        table_alias ||= next_alias!

        klass = subject.klass
        base_class = klass.base_class
        select_sql = coalesce(json_agg(json_build_object(visit(klass.trait_manager, trait: trait, table_alias: table_alias)))).to_sql
        from_sql = subject.to_sql

        base_class.select(select_sql).from("#{as(from_sql, table_alias)}")
      end

      def visit_class(subject, trait: :default, **kwargs)
        visit(subject.all, trait: trait, **kwargs)
      end

      def visit_trait_manager(subject, trait: :default, **kwargs)
        visit subject.get_trait(trait), **kwargs
      end

      def visit_trait(subject, **kwargs)
        subject.attribute_nodes.map { |attribute| visit attribute, **kwargs }.join(', ')
      end

      def visit_node(subject, **kwargs)
        case subject
        when attribute? then visit_attribute subject, **kwargs
        when association? then visit_association subject, **kwargs
        else raise UnknownAttributeError.new
        end
      end

      def visit_attribute(subject, table_alias: nil)
        return visit_enum(subject, table_alias: table_alias) if subject.enum?
        table_alias ||= alias_tracker
        key = "\'#{subject.label}\'"
        column_name = "\"#{table_alias}\".\"#{subject.column_name}\""
        val = subject.prc ? subject.prc.call(column_name) : column_name
        "#{key}, #{val}"
      end

      def visit_enum(subject, table_alias: nil)
        key = "\'#{subject.label}\'"
        enum_hash = subject.klass.defined_enums[subject.column_name.to_s]
        val = "CASE \"#{table_alias}\".\"#{subject.column_name}\" " +
        enum_hash.map do |enum_key, enum_value|
          "WHEN #{enum_value.is_a?(String) ? "'#{enum_value}'" : enum_value} THEN \'#{subject.prc ? subject.prc.call(enum_key) : enum_key}\'"
        end.join(' ') + " ELSE NULL END"
        "#{key}, #{val}"
      end

      def visit_association(subject, **kwargs)
        send("visit_#{subject.type}", subject, **kwargs)
      end

      def visit_belongs_to(subject, table_alias:, **kwargs)
        current_alias = next_alias!
        klass = subject.target
        select_sql = json_build_object(visit(klass.trait_manager, trait: subject.trait, table_alias: current_alias)).to_sql
        query = klass.select(select_sql).from("#{klass.table_name} #{current_alias}")
                .where("#{current_alias}.#{subject.primary_key}=#{table_alias}.#{subject.foreign_key}").to_sql
        "\'#{subject.label}\', (#{query})"
      end

      def visit_has_many(subject, table_alias:, **kwargs)
        return visit_has_many_through(subject, table_alias: table_alias, **kwargs) if subject.association.through_reflection?

        current_alias = next_alias!
        klass = subject.target
        select_sql = coalesce(json_agg(json_build_object(visit(klass.trait_manager, trait: subject.trait, table_alias: current_alias)))).to_sql

        query = klass.select(select_sql).from("#{klass.table_name} #{current_alias}")
                .where("#{current_alias}.#{subject.primary_key}=#{table_alias}.#{subject.foreign_key}").to_sql

        "\'#{subject.label}\', (#{query})"
      end

      def visit_has_many_through(subject, table_alias:, **kwargs)
        current_alias = next_alias!
        association = subject.association
        through = association.through_reflection
        source = association.source_reflection
        join_name = source.collection? ? through.plural_name.to_sym : through.name
        # needs work
        where_clause = begin
          if source.belongs_to?
            "#{table_alias}.#{through.join_foreign_key}=#{through.table_name}.#{through.join_primary_key}"
          elsif through.belongs_to?
            "#{table_alias}.#{through.join_foreign_key}=#{through.table_name}.#{subject.foreign_key}"
          else
            "#{through.table_name}.#{through.join_foreign_key}=#{table_alias}.#{subject.foreign_key}"
          end
        end

        query = visit(association
          .klass
          .joins(join_name)
          .where(where_clause), table_alias: current_alias)
          .to_sql

        "\'#{subject.label}\', (#{query})"
      end

      def visit_has_and_belongs_to_many(subject, table_alias:, **kwargs)
        current_alias = next_alias!
        association = subject.association
        join_table = association.join_table
        source = association.source_reflection

        query = visit(association
          .klass
          .select("#{source.table_name}.*, #{join_table}.#{source.association_foreign_key}, #{join_table}.#{association.join_primary_key}")
          .joins("INNER JOIN #{join_table} ON #{join_table}.#{source.association_foreign_key}=#{source.table_name}.#{source.association_primary_key}"), table_alias: current_alias)
          .where("#{current_alias}.#{association.join_primary_key}=#{table_alias}.#{subject.foreign_key}")
          .to_sql

        "\'#{subject.label}\', (#{query})"
      end

      def visit_has_one(subject, table_alias:, **kwargs)
        current_alias = next_alias!
        subquery_alias = next_alias!
        klass = subject.target

        select_sql = json_build_object(visit(klass.trait_manager, trait: subject.trait, table_alias: current_alias)).to_sql
        from_sql = klass
          .select("DISTINCT ON (#{subject.primary_key}) #{subquery_alias}.*")
          .from("#{klass.table_name} #{subquery_alias}")

        query = klass.select(select_sql).from("#{as(from_sql, current_alias)}")
          .where("#{current_alias}.#{subject.primary_key}=#{table_alias}.#{subject.foreign_key}").to_sql

        "\'#{subject.label}\', (#{query})"
      end

      private

      def alias_tracker
        @alias ||= 'a0'
      end

      def next_alias!
        alias_tracker.next!.dup
      end

      def as(sql, table_alias)
        PgSerializable::Nodes::As.new(sql, table_alias)
      end

      def json_build_object(sql)
        PgSerializable::Nodes::JsonBuildObject.new(sql)
      end

      def json_agg(sql)
        PgSerializable::Nodes::JsonAgg.new(sql)
      end

      def coalesce(sql)
        PgSerializable::Nodes::Coalesce.new(sql, PgSerializable::Nodes::JsonArray.new)
      end
    end
  end
end
