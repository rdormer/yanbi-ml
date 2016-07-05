# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'version'

Gem::Specification.new do |spec|
  spec.name          = "yanbi-ml"
  spec.version       = Yanbi::VERSION
  spec.authors       = ["Robert Dormer"]
  spec.email         = ["rdormer@gmail.com"]

  spec.summary       = %q{Yet Another Naive Bayes Implementation}
  spec.homepage      = "http://github.com/rdormer/yanbi-ml"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.4.0"
  spec.add_dependency "fast-stemmer", "~> 1.0.2"
end
