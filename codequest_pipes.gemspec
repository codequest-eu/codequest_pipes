# encoding: utf-8

Gem::Specification.new do |spec|
  spec.name    = 'codequest_pipes'
  spec.version = '0.3.2'

  spec.author      = 'codequest'
  spec.email       = 'hello@codequest.com'
  spec.description = 'Pipes provides a Unix-like way to chain business objects'
  spec.summary     = 'Unix-like way to chain business objects (interactors)'
  spec.homepage    = 'https://github.com/codequest-eu/codequest_pipes'
  spec.license     = 'MIT'

  spec.files      = Dir['lib/**/*.rb'] + Dir['spec/**/*.rb']
  spec.test_files = spec.files.grep(/^spec/)

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.9'

  spec.add_dependency 'ice_nine', '~> 0.11'
end
