require "spec_helper"

describe "Song" do
  
  context "album" do
    before do
      stub_request(:get, "http://grooveshark.com/").
        to_return(
          :status => 200, :body => "",
          :headers => {
            'Set-Cookie' => 'PHPSESSID=8d5e0200564abe281e7e98435e40ee16;'
          }
        )
      stub_request(:post, api_secure_url('getCommunicationToken')).
        to_return(
          :status => 200,
          :body => fixture('get_communication_token.json')
        )
      stub_request(:post, api_url('getAlbumByID')).
        to_return(
          :status => 200,
          :body => fixture('get_album_by_id.json')
        )
      stub_request(:post, "http://cowbell.grooveshark.com/more.php?method=albumGetSongs").
        to_return(
          :status => 200,
          :body => fixture('album_get_songs.json')
        )
      @client = Grooveshark::Client.new
      @song = Grooveshark::Song.new(@client, {'album_id' => '4526300', 'song_id' => '26832592'})
    end
    
    it "should return album object if called album getter" do
      @song.album.should be_a_kind_of Grooveshark::Album
    end
    
    it "should have at least one song" do
      @song.album.songs.count.should > 0
    end
    
    it "should have the song name in it" do
      songs = @song.album.songs.map { |s| s.id }
      songs.include?(@song.id.to_s).should be_true
    end
    
  end
  
  # context "artist" do
  #   it "should return artist object if called artist getter" do
  #     @song.artist.should be_a_kind_of Grooveshark::Artist
  #   end
  # end
  
end