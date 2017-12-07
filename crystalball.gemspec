# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crystalball/version'

Gem::Specification.new do |spec|
  spec.name          = "crystalball"
  spec.version       = Crystalball::VERSION
  spec.authors       = ["Pavel Shutsin"]
  spec.email         = ["publicshady@gmail.com"]

  spec.summary       = 'A library for RSpec regression test selection'
  spec.description   = 'Provides simple way to integrate regression test selection approach to your RSpec test suite'
  spec.homepage      = 'https://github.com/toptal/crystalball'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.require_paths = ["lib"]

  spec.add_dependency 'git'

  spec.required_ruby_version = '> 2.3.0'

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
end
