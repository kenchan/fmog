# frozen_string_literal: true

require_relative "lib/fmog/version"

Gem::Specification.new do |spec|
  spec.name = "fmog"
  spec.version = Fmog::VERSION
  spec.authors = ["Kenichi Takahashi"]
  spec.email = ["kenichi.taka@gmail.com"]
  spec.summary = "Feed MogMog - CLI feed aggregator"
  spec.description = "fmog (Feed MogMog) is a command-line RSS/Atom feed aggregator. Subscribe to feeds, fetch updates, and read items — all from your terminal, with JSON output for piping."
  spec.homepage = "https://github.com/kenchan/fmog"
  spec.license = "MIT"

  spec.required_ruby_version = ">= 4.0"

  spec.metadata = {
    "source_code_uri" => "https://github.com/kenchan/fmog",
    "changelog_uri" => "https://github.com/kenchan/fmog/blob/main/CHANGELOG.md",
    "rubygems_mfa_required" => "true"
  }

  spec.files = Dir["lib/**/*.rb", "sig/**/*.rbs", "exe/*"]
  spec.bindir = "exe"
  spec.executables = ["fmog"]

  spec.add_dependency "rss", "~> 0.3"
  spec.add_dependency "sqlite3", "~> 2.0"
  spec.add_dependency "thor", "~> 1.3"
  spec.add_dependency "terminal-table", "~> 3.0"
  spec.add_dependency "xdg", "~> 10.0"

  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rbs", "~> 3.0"
  spec.add_development_dependency "steep", "~> 1.9"
end
