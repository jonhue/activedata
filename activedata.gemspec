# frozen_string_literal: true

require File.expand_path(
  File.join('..', 'lib', 'active_data', 'version'),
  __FILE__
)

Gem::Specification.new do |gem|
  gem.name                  = 'activedata'
  gem.version               = ActiveData::VERSION
  gem.platform              = Gem::Platform::RUBY
  gem.summary               = 'Object-Relational-Mapping in Rails with '\
                              'consistent JSON data'
  gem.description           = 'Object-Relational-Mapping in Rails with '\
                              'consistent JSON data.'
  gem.authors               = 'Jonas Hübotter'
  gem.email                 = 'me@jonhue.me'
  gem.homepage              = 'https://github.com/jonhue/activedata'
  gem.license               = 'MIT'

  gem.files                 = Dir['README.md', 'LICENSE', 'lib/**/*',
                                  'app/**/*']
  gem.require_paths         = ['lib']

  gem.required_ruby_version = '>= 2.0'

  gem.add_dependency 'activemodel', '>= 5.0'
  gem.add_dependency 'activesupport', '>= 5.0'
  gem.add_dependency 'railties', '>= 5.0'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rubocop'
  gem.add_development_dependency 'rubocop-rspec'
end
