require 'pg_serializable'

class ApplicationRecord < ActiveRecord::Base
  include PgSerializable

  self.abstract_class = true
end
