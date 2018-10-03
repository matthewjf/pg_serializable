module PgSerializable
  class Aliaser
    def initialize(current=nil)
      @current = current || 'a0'
    end

    def next!
      @current = @current.next
    end

    def to_s
      @current
    end
  end
end
