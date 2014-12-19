# encoding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "what3words/version"

Gem::Specification.new do |spec|
  spec.name = "what3words"
  spec.version = What3Words::VERSION
  spec.authors = ["Asfand Yar Qazi"]
  spec.email = ["ayqazi@gmail.com"]
  spec.summary = "Query the what3words API in Ruby"
  spec.homepage = "http://rubygems.org/gems/what3words"
  spec.license = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rest-client"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"
end
