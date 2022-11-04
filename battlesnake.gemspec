require_relative 'lib/battlesnake/version'

Gem::Specification.new do |spec|
  spec.name          = "battlesnake"
  spec.version       = Battlesnake::VERSION
  spec.authors       = ["Jaime Bellmyer"]
  spec.email         = ["ruby@bellmyer.com"]

  spec.summary       = %q{Object modeling and helpful methods for building Battlesnake players.}
  spec.description   = %q{Focus on strategy, rather than the low-level mapping of JSON objects.}
  spec.homepage      = "https://github.com/bellmyer/battlesnake"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|Guardfile|doc|tmp)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'rspec', '~> 3.12.0'
  spec.add_development_dependency 'guard', '~> 2.18.0'
  spec.add_development_dependency 'guard-rspec', '~> 4.7.3'
  spec.add_development_dependency 'yard', '~> 0.9.28'
  spec.add_development_dependency 'fabrication', '~> 2.30.0'
end
