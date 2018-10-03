module PgSerializable
  module Nodes
    class Base
      def to_s
        to_sql
      end
    end
  end
end
