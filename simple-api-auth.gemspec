lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple-api-auth/version'

Gem::Specification.new do |spec|
  spec.name          = 'simple-api-auth'
  spec.version       = SimpleApiAuth::VERSION
  spec.authors       = ['Daniel Perez']
  spec.email         = ['daniel@claudetech.com']
  spec.summary       = 'Basic token based authentication for APIs'
  spec.homepage      = 'https://github.com/claudetech/ruby-simple-api-auth'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = Dir['specs/**/*']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'coveralls', '~> 0.7'
  spec.add_development_dependency 'activerecord', ['>= 3', '< 5']
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'sqlite3'
end
