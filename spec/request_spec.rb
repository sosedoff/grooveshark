require File.expand_path("./helper", File.dirname(__FILE__))

describe 'Request' do
  module Grooveshark
    module Request
      # Override default ttl for tests
      remove_const :TOKEN_TTL # Avoid the "already initialized constant" warning
      TOKEN_TTL = 1
    end
  end
  
  it 'should obtain a new communication token on TTL expiration' do
    @gs = Grooveshark::Client.new
    @tokens = []
    
    3.times do |i|
      @gs.search_songs('Muse')
      @tokens << @gs.comm_token
      sleep 3
    end
    
    @tokens.uniq!
    @tokens.size.should == 3
  end
end
