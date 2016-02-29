# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "organizer/version"

Gem::Specification.new do |spec|
  spec.name          = "organizer"
  spec.version       = Organizer::VERSION
  spec.authors       = ["Leandro Segovia"]
  spec.email         = ["ldlsegovia@gmail.com"]

  spec.summary       = "Gem to perform different actions over denormalized data"
  spec.description   = "Organizer allows you to perform filtering, ordering and operations over denormalized data"
  spec.homepage      = "https://github.com/ldlsegovia/organizer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "~> 4.2", ">= 4.2.0"
  spec.add_dependency "colorize", "~> 0.7", ">= 0.7.7"
  spec.add_dependency "require_all", "~> 1.3", ">= 1.3.3"
  spec.add_dependency "pry-byebug", "~> 3.1", ">= 3.1.0"

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2", ">= 3.2.0"
  spec.add_development_dependency "rspec-nc", "~> 0.2", ">= 0.2.0"
  spec.add_development_dependency "guard", "~> 2.12", ">= 2.12.5"
  spec.add_development_dependency "guard-rspec", "~> 4.5", ">= 4.5.0"
  spec.add_development_dependency "simplecov", "~> 0.10", ">= 0.10.0"
end
