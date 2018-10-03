require "pg_serializable/version"
require "active_support/concern"

module PgSerializable
  extend ActiveSupport::Concern
  included do
    def json
      ActiveRecord::Base.connection.select_one(
        self.class.where(id: id).limit(1).as_json_object.to_sql
      )['json_build_object']
    end
  end

  class_methods do
    def json
      ActiveRecord::Base.connection.select_one(
        serializer.as_json_array(pg_scope, Aliaser.new).to_sql
      )['coalesce']
    end

    def as_json_array(table_alias = Aliaser.new)
      serializer.as_json_array(pg_scope, table_alias)
    end

    def as_json_object(table_alias = Aliaser.new)
      serializer.as_json_object(pg_scope, table_alias)
    end

    def serializable(&blk)
      serializer.instance_eval &blk
      serializer.check_for_cycles!
    end

    def serializer
      @serializer ||= Serializer.new(self)
    end

    def pg_scope
      respond_to?(:to_sql) ? self : all
    end
  end
end
