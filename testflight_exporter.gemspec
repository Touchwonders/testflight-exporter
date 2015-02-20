# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'testflight_exporter/version'

Gem::Specification.new do |spec|
  spec.name          = "TestFlightExporter"
  spec.version       = TestFlightExporter::VERSION
  spec.authors       = ["Fabio Milano"]
  spec.email         = ["fabio@touchwonders.com"]
  spec.summary       = %q{A simple tool that helps you migrating your TestFlight binaries to your local environment}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "mechanize", '~> 2.7' # to parse www pages
  spec.add_dependency 'highline', '~> 1.6' # user inputs (e.g. passwords)
  spec.add_dependency 'colored' # coloured terminal output
  spec.add_dependency 'commander', '~> 4.2' # CLI parser

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end