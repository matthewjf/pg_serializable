module PgSerializable
  class TraitManager
    include PgSerializable::Visitable

    attr_reader :klass, :traits

    def initialize(klass)
      @klass = klass
      @traits = ActiveSupport::HashWithIndifferentAccess.new
    end

    def default(&blk)
      default_trait = PgSerializable::Trait.new(klass)
      default_trait.instance_eval &blk
      @traits[:default] = default_trait
    end

    def trait(trait_name, &blk)
      trait_instance = PgSerializable::Trait.new(klass)
      trait_instance.instance_eval &blk
      @traits[trait_name] = trait_instance
    end

    def get_trait(trait)
      @traits[trait]
    end

    def validate_traits!
      accept(PgSerializable::Visitors::Validation.new)
    end
  end
end
