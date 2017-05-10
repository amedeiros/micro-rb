# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'micro/version'

Gem::Specification.new do |spec|
  spec.name          = 'micro-rb'
  spec.version       = MicroRb::VERSION
  spec.authors       = ['Andrew Medeiros']
  spec.email         = ['andrew@amedeiros.com']

  spec.summary       = 'Write micro services in Ruby for the Micro framework'
  spec.homepage      = 'https://github.com/amedeiros/micro-rb'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required'\
          'to protect against public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'bin'
  spec.executables   = ['microrb']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake',     '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'minitest-reporters', '~> 1.1'
  spec.add_development_dependency 'shoulda', '~> 3.5'

  spec.add_runtime_dependency 'activesupport', '~> 5.1', '>= 5.1.0'
  spec.add_runtime_dependency 'httparty', '~> 0.14.0'
  spec.add_runtime_dependency 'multi_json', '~> 1.12', '>= 1.12.1'
  spec.add_runtime_dependency 'rack', '~> 1.6', '>= 1.6.5'
  spec.add_runtime_dependency 'semantic_logger', '~> 4.0', '>= 4.0.0'
  spec.add_runtime_dependency 'google-protobuf', '~> 3.3', '>= 3.3.0'
end
