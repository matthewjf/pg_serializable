
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pg_serializable/version"

Gem::Specification.new do |spec|
  spec.name          = "pg_serializable"
  spec.version       = PgSerializable::VERSION
  spec.authors       = ["matthewjf"]
  spec.email         = ["matthewjf@gmail.com"]

  spec.summary       = %q{serializes rails models from postgres (9.5+)}
  spec.description   = %q{serializes rails models from postgres (9.5+)}
  spec.homepage      = "https://github.com/matthewjf/pg_serializable"
  spec.license       = "MIT"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "codecov"
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "factory_bot"
  spec.add_development_dependency "ffaker"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_runtime_dependency "activesupport", ">= 5.2", "< 7.0"
  spec.add_runtime_dependency "activerecord", ">= 5.2", "< 7.0"
  spec.add_runtime_dependency "pg", ">= 1.1"
end
