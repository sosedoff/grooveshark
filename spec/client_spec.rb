require File.expand_path("./helper", File.dirname(__FILE__))

describe 'Client' do
  context 'initialization' do
    it 'should have a valid session' do
      @gs = Grooveshark::Client.new
      @gs.session.should_not == nil
      @gs.session.should match /^[abcdef\d]{32}$/i
    end

    it 'should have a valid country' do
      gs = Grooveshark::Client.new
      gs.country.should be_a_kind_of Hash
      gs.country.size.should == 7
    end

    it 'should have a valid token' do
      @gs = Grooveshark::Client.new
      @gs.comm_token.should_not == nil
      @gs.comm_token.should match /^[abcdef\d]{13}$/i
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

  context 'download' do
    it 'should download without being banned' do
      4.times do # Usually the IP is banned on the 4th request on protocol mismatch
        gs = Grooveshark::Client.new
        # Try with a short song (this one is about a minute long)
        song = gs.search_songs("Alan Reeves The Chase").first
        url = gs.get_song_url(song)
        file = RestClient::Request.execute(:method => :post, :url => url, :raw_response => true).file
        case mime_type = `file -b --mime-type #{file.path}`.strip
        when /^audio\//
          # This is the expected type
        when /^application\/octet-stream$/
          # Sometimes the file type can't be detected and this type is returned. At least we 
          # check it's big enough to be an audio file.
          file.size.should >= 500 * 1024
        else
          raise RSpec::Expectations::ExpectationNotMetError, "Unknown MIME type (#{mime_type})"
        end
      end
    end
  end
end
