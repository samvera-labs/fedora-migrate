# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fedora_migrate/version'

Gem::Specification.new do |spec|
  spec.name          = "fedora-migrate"
  spec.version       = FedoraMigrate::VERSION
  spec.authors       = ["Adam Wead"]
  spec.email         = ["amsterdamos@gmail.com"]
  spec.summary       = %q{Migrate Hydra-based repository data from Fedora3 to Fedora4}
  spec.description   = %q{Migrates data (models, datastreams, content) from a Fedora3 repository to Fedora4}
  spec.homepage      = ""
  spec.license       = "APACHE2"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rubydora", "~> 1.8"
  spec.add_dependency "rchardet"
  
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "equivalent-xml"
  spec.add_development_dependency "curation_concerns", '>= 1.0.0.beta1', '< 2'
  spec.add_development_dependency "jettywrapper"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-its"
end
