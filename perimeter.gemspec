lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'perimeter/version'

Gem::Specification.new do |spec|
  spec.name          = 'perimeter'
  spec.version       = Perimeter::VERSION
  spec.authors       = %w{ perimeter }
  spec.description   = %q{Repository/Entity pattern conventions.}
  spec.summary       = %q{Repository/Entity pattern conventions.}
  spec.homepage      = 'https://github.com/bukowskis/perimeter'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/) - ['.travis.yml']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w{ lib }

  spec.add_dependency 'virtus'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'hooks'
  spec.add_dependency 'operation'
  spec.add_dependency 'trouble'

  #spec.add_dependency 'activemodel' # Not compatible with Rails 2, backport it if neccessary
  spec.add_development_dependency 'activemodel'
  spec.add_development_dependency 'activerecord'
  spec.add_development_dependency 'sqlite3'

  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'guard-bundler'
end
