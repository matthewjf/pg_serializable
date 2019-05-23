require "pg"
require "active_record"

DATABASE = 'pg_serializable_test'

ActiveRecord::Base.establish_connection(adapter: 'postgresql')
ActiveRecord::Base.connection.drop_database(DATABASE)
ActiveRecord::Base.connection.create_database(DATABASE)
