# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'influxdb_setup/version'

Gem::Specification.new do |spec|
  spec.name          = "influxdb_setup"
  spec.version       = InfluxdbSetup::VERSION
  spec.authors       = ["Donald Plummer"]
  spec.email         = ["dplummer@avvo.com"]

  spec.summary       = %q{Rake task for setting up an influxdb database and queries}
  spec.homepage      = "http://gitlab.corp.avvo.com/avvo/influxdb_setup"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "influxdb", "~> 0.1.9"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
