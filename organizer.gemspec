# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'organizer/version'

Gem::Specification.new do |spec|
  spec.name          = "organizer"
  spec.version       = Organizer::VERSION
  spec.authors       = ["Leandro Segovia"]
  spec.email         = ["ldlsegovia@gmail.com"]

  spec.summary       = "Gem to perform different actions over denormalized data"
  spec.description   = "Organizer allows you to perform filtering, ordering and operations over denormalized data"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "colorize"
  spec.add_dependency "require_all"

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-nc"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "simplecov"
end
