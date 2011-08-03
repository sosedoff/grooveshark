$LOAD_PATH << '.' if RUBY_VERSION > '1.8'

require 'rubygems'
require 'grooveshark'

client = Grooveshark::Client.new

puts client.songs('Nirvana').inspect
