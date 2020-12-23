$:.push File.expand_path("../lib/embulk/input", __FILE__)
require "hubspot/version"

Gem::Specification.new do |spec|
  spec.name          = "embulk-input-hubspot"
  spec.version       = Embulk::Input::HubspotApi::VERSION
  spec.authors       = ["kazuki-yane"]
  spec.summary       = "Hubspot input plugin for Embulk"
  spec.description   = "Loads records from Hubspot."
  spec.email         = ["yanekazuki@yahoo.co.jp"]
  spec.licenses      = ["MIT"]
  # TODO set this: spec.homepage      = "https://github.com/yanekazuki/embulk-input-hubspot"

  spec.files         = `git ls-files`.split("\n") + Dir["classpath/*.jar"]
  spec.test_files    = spec.files.grep(%r{^(test|spec)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'hubspot-api-client', ['~> 7.0.0']

  #spec.add_dependency 'YOUR_GEM_DEPENDENCY', ['~> YOUR_GEM_DEPENDENCY_VERSION']
  spec.add_development_dependency 'embulk', ['>= 0.9.23']
  spec.add_development_dependency 'bundler', ['>= 1.10.6']
  spec.add_development_dependency 'rake', ['>= 10.0']
end
