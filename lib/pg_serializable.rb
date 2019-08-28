require 'oj'
require 'active_support/concern'
require 'active_support/core_ext/module/delegation'
require 'pg_serializable/errors'
require 'pg_serializable/visitable'
require 'pg_serializable/nodes'
require 'pg_serializable/trait_manager'
require 'pg_serializable/trait'
require 'pg_serializable/visitors'

module ActiveRecord
  class Relation
    include PgSerializable::Visitable

    def json(trait: :default)
      to_pg_json accept(PgSerializable::Visitors::Json.new, trait: trait)
    end
  end
end

module PgSerializable
  extend ActiveSupport::Concern

  def self.validate_traits!
    ActiveRecord::Base.descendants.each do |klass|
      begin
        klass.validate_traits!
      rescue NoMethodError, ActiveRecord::NoDatabaseError
      end
    end
  end

  included do
    include Visitable

    def json(trait: :default)
      self.class.to_pg_json accept(PgSerializable::Visitors::Json.new, trait: trait)
    end
  end

  class_methods do
    def json(trait: :default)
      to_pg_json accept(PgSerializable::Visitors::Json.new, trait: trait)
    end

    def serializable(&blk)
      trait_manager.instance_eval &blk
    end

    def trait_manager
      @trait_manager ||= TraitManager.new(self)
    end

    def accept visitor, **kwargs
      visitor.visit self, **kwargs
    end

    def to_pg_json(scope)
      res = scope.as_json.first
      res['coalesce'] || res['json_build_object']
    end

    private

    delegate :validate_traits!, to: :trait_manager
  end
end
