require 'active_support'
require 'active_support/dependencies'

ActiveSupport::Dependencies.autoload_paths = [
  "spec/models"
]
