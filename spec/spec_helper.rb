require "bundler/setup"
require "pg_serializable"
require "factory_bot"
require "pry"

require_relative 'support/database.rb'
require_relative 'support/schema.rb'
require_relative 'support/autoload.rb'
require_relative 'models/application_record'

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.include FactoryBot::Syntax::Methods

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
