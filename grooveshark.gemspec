# -*- encoding: utf-8 -*-
require File.expand_path('../lib/grooveshark/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = "grooveshark"
  gem.version     = Grooveshark::VERSION
  gem.description = "Unofficial ruby library for consuming the Grooveshark API."
  gem.summary     = "Grooveshark API"
  gem.authors     = ["Dan Sosedoff"]
  gem.email       = "dan.sosedoff@gmail.com"
  gem.homepage    = "http://github.com/sosedoff/grooveshark"

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  gem.require_paths = ['lib']
  
  gem.add_development_dependency 'rspec',              '~> 2.6'
  gem.add_runtime_dependency     'faraday',            '~> 0.7.4'
  gem.add_runtime_dependency     'faraday_middleware', '~> 0.7.0'
  gem.add_runtime_dependency     'multi_json',         '~> 1.0.3'
end