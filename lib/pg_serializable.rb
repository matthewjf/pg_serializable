require 'oj'
require 'active_support/concern'
require 'pg_serializable/errors'
require 'pg_serializable/visitable'
require 'pg_serializable/nodes'
require 'pg_serializable/trait_manager'
require 'pg_serializable/trait'
require 'pg_serializable/visitors'

module ActiveRecord
  class Relation
    include PgSerializable::Visitable

    def json
      to_pg_json accept(PgSerializable::Visitors::Json.new)
    end
  end
end

module PgSerializable
  extend ActiveSupport::Concern

  included do
    include Visitable

    def json
      self.class.to_pg_json accept(PgSerializable::Visitors::Json.new)
    end
  end

  class_methods do
    def json
      to_pg_json accept(PgSerializable::Visitors::Json.new)
    end

    def serializable(&blk)
      trait_manager.instance_eval &blk
      validate_traits!
    end

    def trait_manager
      @trait_manager ||= TraitManager.new(self)
    end

    def accept visitor, **kwargs
      visitor.visit self, **kwargs
    end

    def to_pg_json(scope)
      res = scope.as_json.first
      ::Oj.dump(res['coalesce'] || res['json_build_object'])
    end

    private

    delegate :validate_traits!, to: :trait_manager
  end
end
