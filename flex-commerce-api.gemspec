# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'flex_commerce/api/version'

Gem::Specification.new do |spec|
  spec.name          = "flex-commerce-api"
  spec.version       = FlexCommerce::Api::VERSION
  spec.authors       = ["Gary Taylor"]
  spec.email         = ["gary.taylor@flexcommerce.com"]

  spec.summary       = %q{Access the flex-commerce API}
  spec.description   = %q{Allows any ruby application to access the flex-commerce API}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_development_dependency "webmock", "~> 1.21"
end
