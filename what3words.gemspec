# encoding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "what3words/version"

Gem::Specification.new do |spec|
  spec.name = "what3words"
  spec.version = What3Words::VERSION
  spec.authors = ["what3words"]
  spec.email = ["development@what3words.com"]
  spec.summary = "what3words API wrapper in Ruby"
  spec.homepage = "http://rubygems.org/gems/what3words"
  spec.license = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rest-client", "~> 1.8"

  spec.add_development_dependency "bundler", ">= 1.7.9"
  spec.add_development_dependency "rake", "~> 11.1"
  spec.add_development_dependency "rspec", "~> 3.4"
end
