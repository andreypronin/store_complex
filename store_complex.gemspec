# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'store_complex/version'

Gem::Specification.new do |spec|
  spec.name          = 'store_complex'
  spec.version       = StoreComplex::VERSION
  spec.authors       = ['moonfly (Andrey Pronin)']
  spec.email         = ['moonfly.msk@gmail.com']
  spec.summary       = %q{Store complex data (arrays, hashes) in hstore attributes}
  spec.description   = <<-EOF
  Stores complex data that includes Arrays and Hashes (possibly nested) in an attribute inside hstore field. 
  The most typical usage scenario is storing arrays in hstore, but it can handle more complex cases.
  EOF
  spec.homepage      = 'https://github.com/moonfly/store_complex'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  
  spec.rdoc_options = ['--charset=UTF-8']
  spec.extra_rdoc_files = %w[README.md CONTRIBUTORS.md LICENSE.md]
  
  spec.required_ruby_version = '>= 2.1.0'

  spec.add_dependency 'rails', '>= 4.0'
  spec.add_dependency 'observable_object'

  spec.add_development_dependency 'bundler', '>= 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.1'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'dotenv'
end
