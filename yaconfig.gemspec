# -*- encoding: utf-8 -*-
require File.expand_path('../lib/yaconfig/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Peter Torkelson"]
  gem.email         = ["peter.torkelson@gmail.com"]
  gem.description   = %q{Yet Another Configuration gem.}
  gem.summary       = %q{Handles both configuration storage and loading.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "yaconfig"
  gem.require_paths = ["lib"]
  gem.version       = Yaconfig::VERSION

  gem.add_dependency('symboltable', '>= 1.0.2')
  gem.add_dependency('version', '>= 1.0.0')
  gem.add_dependency('json', '>= 1.7.5')
end
