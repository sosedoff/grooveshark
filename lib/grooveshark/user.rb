# Grooveshark module
module Grooveshark
  # User class
  class User
    attr_reader :id, :name, :email, :premium, :data
    attr_reader :city, :country, :sex
    attr_reader :playlists, :favorites

    # Init user account object
    def initialize(client, data = nil)
      if data
        @data     = data
        @id       = data['user_id']
        @name     = data['f_name']
        @premium  = data['is_premium']
        @email    = data['email']
        @city     = data['city']
        @country  = data['country']
        @sex      = data['sex']
      end
      @client     = client
    end

    # Get user avatar URL
    def avatar
      "http://images.grooveshark.com/static/userimages/#{@id}.jpg"
    end

    # Get user activity for the date (COMES AS RAW RESPONSE)
    def feed(date = nil)
      date = Time.now if date.nil?
      @client.request('getProcessedUserFeedData',
                      userID: @id,
                      day: date.strftime('%Y%m%d'))
    end

    # --------------------------------------------------------------------------
    # User Library
    # --------------------------------------------------------------------------

    # Fetch songs from library
    def library(page = 0)
      songs = []
      resp = @client.request('userGetSongsInLibrary',
                             userID: @id,
                             page: page.to_s)
      songs = resp['songs'].map do |song|
        Song.new song
      end if resp.key?('songs')
      songs
    end

    # Add songs to user's library
    def library_add(songs = [])
      @client.request('userAddSongsToLibrary', songs: songs.map(&:to_hash))
    end

    # Remove song from user library
    def library_remove(song)
      fail ArgumentError, 'Song object required' unless song.is_a?(Song)
      req = { userID: @id,
              songID: song.id,
              albumID: song.album_id,
              artistID: song.artist_id }
      @client.request('userRemoveSongFromLibrary', req)
    end

    # Get library modification time
    def library_ts_modified
      @client.request('userGetLibraryTSModified', userID: @id)
    end

    # --------------------------------------------------------------------------
    # User Playlists
    # --------------------------------------------------------------------------

    # Fetch user playlists
    def playlists
      return @playlists if @playlists
      results = @client.request('userGetPlaylists', userID: @id)
      @playlists = results['playlists'].map do |list|
        Playlist.new(@client, list, @id)
      end
    end

    # Get playlist by ID
    def get_playlist(id)
      result = playlists.select { |p| p.id == id }
      result.nil? ? nil : result.first
    end

    alias_method :playlist, :get_playlist

    # Create new user playlist
    def create_playlist(name, description = '', songs = [])
      @client.request('createPlaylist',
                      'playlistName' => name,
                      'playlistAbout' => description,
                      'songIDs' => songs.map do |s|
                        s.is_a?(Song) ? s.id : s.to_s
                      end)
    end

    # --------------------------------------------------------------------------
    # User Favorites
    # --------------------------------------------------------------------------

    # Get user favorites
    def favorites
      return @favorites if @favorites
      resp = @client.request('getFavorites', ofWhat: 'Songs', userID: @id)
      @favorites = resp.map { |s| Song.new(s) }
    end

    # Add song to favorites
    def add_favorite(song)
      song_id = song.is_a?(Song) ? song.id : song
      @client.request('favorite', what: 'Song', ID: song_id)
    end

    # Remove song from favorites
    def remove_favorite(song)
      song_id = song.is_a?(Song) ? song.id : song
      @client.request('unfavorite', what: 'Song', ID: song_id)
    end
  end
end
