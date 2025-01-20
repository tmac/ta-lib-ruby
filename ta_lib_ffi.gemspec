# frozen_string_literal: true

require_relative "lib/ta_lib"

Gem::Specification.new do |spec|
  spec.name = "ta_lib_ffi"
  spec.version = TALib::VERSION
  spec.authors = ["Victor Yang"]
  spec.email = ["victor@rt4u.bid"]
  spec.summary = "Ruby FFI bindings for TA-Lib (Technical Analysis Library)"
  spec.description = "A Ruby wrapper for TA-Lib using FFI, providing technical analysis functions for financial market data"
  spec.homepage = "https://github.com/Youngv/ta_lib_ffi"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Youngv/ta_lib_ffi"
  spec.metadata["changelog_uri"] = "https://github.com/Youngv/ta_lib_ffi/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "fiddle", "~> 1.1"
  spec.add_development_dependency "byebug", "~> 11.1"
  spec.add_development_dependency "rake", "~> 13.2"
  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "rubocop-rspec", "~> 3.3"
  spec.add_development_dependency "ruby-lsp-rspec", "~> 0.1.20"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
