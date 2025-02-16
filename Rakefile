# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "yard"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[spec rubocop]

YARD::Rake::YardocTask.new do |t|
  require_relative "lib/ta_lib_ffi"
  require_relative "lib/ta_lib_ffi/doc"
  TALibFFI::Doc.insert

  t.files = ["lib/**/*.rb"]
  t.options = ["--exclude", "lib/ta_lib_ffi/doc.rb"]
  t.stats_options = ["--list-undoc"]
  # t.after = -> { TALibFFI::Doc.remove }
end
