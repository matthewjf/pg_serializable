module PgSerializable
  module Nodes
    class Attribute < Base
      attr_reader :column_name, :klass, :label, :prc

      def initialize(klass, column_name, label: nil, &prc)
        @klass = klass
        @column_name = column_name
        @label = label || column_name
        @prc = prc if block_given?
      end
    end
  end
end
