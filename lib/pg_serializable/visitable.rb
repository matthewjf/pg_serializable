module PgSerializable
  module Visitable
    def accept visitor, **kwargs
      visitor.visit self, **kwargs
    end
  end
end
