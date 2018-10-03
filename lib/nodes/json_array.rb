module PgSerializable
  module Nodes
    class JsonArray < Base
      def initialize(*args)
        @args = args
      end

      def to_sql
        "\'[#{@args.join(', ')}]\'::json"
      end
    end
  end
end
