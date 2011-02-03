require File.expand_path("./helper", File.dirname(__FILE__))

describe 'Client' do
  context 'initialization' do
    it 'should have a valid session' do
      @gs = Grooveshark::Client.new
      @gs.session.should_not == nil
      @gs.session.should match /^[abcdef\d]{32}$/i
    end
  end
  
  context 'authentication' do
    it 'should raise InvalidAuthentication error for invalid credentials' do
      @gs = Grooveshark::Client.new
      lambda { @gs.login('invlid_user_name', 'invalid_password') }.should raise_error Grooveshark::InvalidAuthentication
    end
  end
  
  context 'search' do
    before(:all) do
      @gs = Grooveshark::Client.new
    end
    
    it 'should return empty songs collection' do
      songs = @gs.search_songs("@@@@@%%%%%%%@%@%%@")
      songs.should be_a_kind_of Array
      songs.size.should == 0
    end
    
    it 'should return songs collection' do
      songs = @gs.search_songs('Nirvana')
      songs.should be_a_kind_of Array
      songs.size.should_not == 0
    end
  end
end