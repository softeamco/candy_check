lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'candy_check/version'

Gem::Specification.new do |spec|
  spec.name          = 'candy_check'
  spec.version       = CandyCheck::VERSION
  spec.authors       = ['Jonas Thiel']
  spec.email         = ['jonas@thiel.io']
  spec.summary       = 'Check and verify in-app receipts'
  spec.homepage      = 'https://github.com/jnbt/candy_check'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = Gem::Requirement.new('>= 2.0')

  spec.add_dependency 'google-apis-androidpublisher_v3', '~> 0.2'
  spec.add_dependency 'multi_json',        '~> 1.10'
  spec.add_dependency 'thor',              '~> 1.1'

  spec.add_development_dependency 'bundler',         '~> 2.1.4'
  spec.add_development_dependency 'coveralls',       '~> 0.8'
  spec.add_development_dependency 'inch',            '~> 0.7'
  spec.add_development_dependency 'm',               '~> 1.5.0'
  spec.add_development_dependency 'minitest',        '~> 5.10'
  spec.add_development_dependency 'minitest-around', '~> 0.4'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake',            '~> 12.0'
  spec.add_development_dependency 'rubocop',         '~> 0.48'
  spec.add_development_dependency 'timecop',         '~> 0.8'
  spec.add_development_dependency 'webmock',         '~> 3.0'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
