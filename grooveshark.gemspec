Gem::Specification.new do |s|
  s.name = "grooveshark"
  s.version = "0.1.0"
  s.date = "2011-01-08"
  s.description = "Unofficial ruby library for consuming the Grooveshark API."
  s.summary = "Grooveshark API"
  s.authors = ["Dan Sosedoff"]
  s.email = "dan.sosedoff@gmail.com"
  s.homepage = "http://github.com/sosedoff/grooveshark"

  s.files = %w[
    lib/grooveshark.rb
    lib/grooveshark/client.rb
    lib/grooveshark/errors.rb
    lib/grooveshark/playlist.rb
    lib/grooveshark/request.rb
    lib/grooveshark/song.rb
    lib/grooveshark/user.rb
  ]

  s.add_dependency('json','>= 1.4.6')
  s.add_dependency('rest-client', '>= 1.5.1')

  s.has_rdoc = true
  s.rubygems_version = '1.3.7'
end