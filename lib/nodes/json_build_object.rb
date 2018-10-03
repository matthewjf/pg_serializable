module PgSerializable
  module Nodes
    class JsonBuildObject < Base
      def initialize(expression)
        @expression = expression
      end

      def to_sql
        "json_build_object(#{@expression})"
      end
    end
  end
end
