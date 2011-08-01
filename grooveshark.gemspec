require 'lib/grooveshark/version'

Gem::Specification.new do |s|
  s.name        = "grooveshark"
  s.version     = Grooveshark::VERSION
  s.description = "Unofficial ruby library for consuming the Grooveshark API."
  s.summary     = "Grooveshark API"
  s.authors     = ["Dan Sosedoff"]
  s.email       = "dan.sosedoff@gmail.com"
  s.homepage    = "http://github.com/sosedoff/grooveshark"

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  gem.require_paths = ['lib']
  
  s.add_development_dependency 'rspec',       '~> 2.6'
  
  s.add_runtime_dependency     'json',        '>= 1.4.6'
  s.add_runtime_dependency     'rest-client', '>= 1.5.1'
end