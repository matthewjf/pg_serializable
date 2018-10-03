module PgSerializable
  module Nodes
    class Coalesce < Base
      def initialize(*args)
        @args = args
      end

      def to_sql
        "COALESCE(#{@args.join(', ')})"
      end
    end
  end
end
