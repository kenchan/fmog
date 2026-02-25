# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "fmog"
  spec.version = "0.1.0"
  spec.authors = ["kenchan"]
  spec.summary = "Feed MogMog - CLI feed aggregator"

  spec.required_ruby_version = ">= 3.0"

  spec.files = Dir["lib/**/*.rb", "exe/*"]
  spec.bindir = "exe"
  spec.executables = ["fmog"]

  spec.add_dependency "rss", "~> 0.3"
  spec.add_dependency "sqlite3", "~> 2.0"
  spec.add_dependency "thor", "~> 1.3"
  spec.add_dependency "terminal-table", "~> 3.0"

  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
