# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = FileList["test/test_*.rb"]
end

desc "Run steep type check"
task :steep do
  sh "bundle exec steep check"
end

desc "Run tests and type check"
task ci: [:test, :steep]

task default: :ci
