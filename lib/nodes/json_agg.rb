module PgSerializable
  module Nodes
    class JsonAgg < Base
      def initialize(expression)
        @expression = expression
      end

      def to_sql
        "json_agg(#{@expression})"
      end
    end
  end
end
