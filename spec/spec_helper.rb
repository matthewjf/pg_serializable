require "bundler/setup"
require "pg_serializable"
require "factory_bot"
require "ffaker"
require "pry"
require "database_cleaner"

require_relative 'support/database.rb'
require_relative 'support/schema.rb'
require_relative 'support/autoload.rb'
require_relative 'models/application_record'

Dir[File.join(__dir__, 'factories/**/*.rb')].each { |f| require f }
Dir[File.join(__dir__, '../models/**/*.rb')].each { |f| require f }

if ENV['CODECOV_TOKEN']
  require 'simplecov'
  require 'codecov'
  SimpleCov.start do
    add_filter "/spec/"
  end
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
