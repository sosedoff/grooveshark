# -*- encoding: utf-8 -*-
require File.expand_path('../lib/grooveshark/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'grooveshark'
  s.version     = Grooveshark::VERSION
  s.description = 'Unofficial ruby library for consuming the Grooveshark API.'
  s.summary     = 'Grooveshark API'
  s.authors     = ['Dan Sosedoff']
  s.email       = 'dan.sosedoff@gmail.com'
  s.homepage    = 'http://github.com/sosedoff/grooveshark'
  s.license     = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map do |f|
    File.basename(f)
  end
  s.require_paths = ['lib']

  s.add_runtime_dependency 'json', '>= 1.4.6'
  s.add_runtime_dependency 'rest-client', '>= 1.5.1'
  s.add_runtime_dependency 'uuid', '~> 2.0'

  s.add_development_dependency 'rake', '~>10.0'
  s.add_development_dependency 'rack-test', '~>0.6'
  s.add_development_dependency 'rspec', '~>3.0'
  s.add_development_dependency 'simplecov', '~>0.9'
  s.add_development_dependency 'fakefs', '~>0.5'

  s.add_development_dependency 'rubocop', '~>0.25' if RUBY_VERSION != '1.9.2'
end
