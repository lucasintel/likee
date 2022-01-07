# frozen_string_literal: true

require_relative 'lib/likee/version'

Gem::Specification.new do |spec|
  spec.name        = 'likee'
  spec.version     = Likee::VERSION
  spec.authors     = ['kandayo']
  spec.email       = ['kdy@absolab.xyz']
  spec.summary     = 'A library designed to provide a stable and straightforward interface to the Likee API.'
  spec.description = spec.summary
  spec.homepage    = 'https://github.com/kandayo/likee'
  spec.license     = 'BSD-3-Clause'

  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issues"
  spec.metadata['changelog_uri'] = "#{spec.homepage}/releases"
  spec.metadata['documentation_uri'] = spec.homepage
  spec.metadata['funding_uri'] = 'https://github.com/sponsors/kandayo'
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = %w[LICENSE.txt README.md] + Dir['lib/**/*']
  spec.bindir = 'exe'
  spec.executables = []
  spec.require_paths = ['lib']

  spec.add_dependency 'net-http-persistent', '~> 4.0'

  spec.add_development_dependency 'factory_bot', '~> 6.2'
  spec.add_development_dependency 'oj', '~> 3.13', '>= 3.13.11'
  spec.add_development_dependency 'pry', '~> 0.14.1'
  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'rubocop', '~> 1.24', '>= 1.24.1'
  spec.add_development_dependency 'simplecov', '~> 0.21.2'
  spec.add_development_dependency 'solargraph', '~> 0.44.2'
  spec.add_development_dependency 'webmock', '~> 3.14'
end
