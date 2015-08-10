# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "flex_commerce_api/version"

Gem::Specification.new do |spec|
  spec.name = "flex_commerce_api"
  spec.version = FlexCommerceApi::VERSION
  spec.authors = ["Gary Taylor"]
  spec.email = ["gary.taylor@flexcommerce.com"]

  spec.summary = "Access the flex-commerce API"
  spec.description = "Allows any ruby application to access the flex-commerce API"
  spec.homepage = "TODO: Put your gem's website or public repo URL here."
  spec.license = "MIT"

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_development_dependency "webmock", "~> 1.21"
  spec.add_development_dependency "factory_girl", "~> 4.5"
  spec.add_development_dependency "faker", "~> 1.4"
  spec.add_development_dependency "yard", "~> 0.8"
  spec.add_development_dependency "json-schema", "~> 2.5"
  spec.add_runtime_dependency "oj", "~> 2.12"

  spec.add_runtime_dependency "json_api_client", "1.0.0.beta6"
  spec.add_runtime_dependency "activesupport", "~> 4"
end
