# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails_config_validator/version'

Gem::Specification.new do |spec|
  spec.name = 'rails_config_validator'
  spec.version = RailsConfigValidator::VERSION
  spec.authors = ['Michał Knapik']
  spec.email = ['michal.knapik@u2i.com']

  spec.summary = %q{Gem for validating Rails YAML configuration files.}
  spec.description = %q{The gem uses Kwalify schema validator to check Rails configuration files syntax.}
  spec.homepage = 'https://github.com/u2i/rails_config_validator'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  end

  spec.add_dependency 'kwalify', '~> 0.7.2'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'u2i-ci_utils', '~> 1.0.2'

  spec.add_development_dependency 'guard-rubocop', '~> 1.2'
  spec.add_development_dependency 'guard-rspec', '~> 4.5'
end
