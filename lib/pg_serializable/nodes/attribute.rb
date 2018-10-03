module PgSerializable
  module Nodes
    class Attribute < Base
      def initialize(column_name, label: nil, &prc)
        @column_name = column_name
        @label = label || column_name
        @prc = prc if block_given?
      end

      def to_sql(table_alias=nil)
        [key, value(table_alias)].join(',')
      end

      private
      def key
        "\'#{@label}\'"
      end

      def value(tbl)
        val = "#{tbl && "#{tbl}."}#{@column_name}"
        @prc ? @prc.call(val) : val
      end
    end
  end
end
