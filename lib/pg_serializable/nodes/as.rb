module PgSerializable
  module Nodes
    class As < Base
      def initialize(scope, table_alias)
        @scope = scope
        @table_alias = table_alias
      end

      def to_sql
        "(#{@scope.respond_to?(:to_sql) ? @scope.to_sql : @scope.to_s}) #{@table_alias}"
      end
    end
  end
end
