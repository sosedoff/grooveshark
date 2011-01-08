module Grooveshark
  class User
    attr_reader :id, :username, :premium, :data
    attr_reader :playlists, :favorites

    # Init user account object
    def initialize(client, data=nil)
      if data
        @data = data
        @id = data['userID']
        @username = data['username']
        @premium = data['isPremium']
      end
      @client = client
    end
    
    # --------------------------------------------------------------------------
    # User Library
    # --------------------------------------------------------------------------
    
    # Fetch songs from library 
    def library(page=0)
      resp = @client.request('userGetSongsInLibrary', {:userID => @id, :page => page.to_s})['Songs']
      resp.map { |s| Song.new(s) }
    end
    
    # Add songs to user library (DOES NOT WORK FOR SOME REASON)
    def library_add(songs=[])
      @client.request('userAddSongsToLibrary', {:songs => songs.map { |s| s.to_hash }})
    end
    
    # Remove song from user library
    def library_remove(song)
      song_id = song.kind_of?(Song) ? song.id : song.to_s
      @client.request('userRemoveSongFromLibrary', {:userID => @id, :songID => song_id})
    end
    
    # --------------------------------------------------------------------------
    # User Playlists
    # --------------------------------------------------------------------------
    
    # Fetch user playlists
    def playlists
      return @playlists if @playlists
      results = @client.request('userGetPlaylists', :userID => @id)
      @playlists = results['Playlists'].map { |list| Playlist.new(@client, list, @id) }
    end
    
    # Get playlist by ID
    def get_playlist(id)
      result = playlists.select { |p| p.id == id }
      result.nil? ? nil : result.first
    end
    
    # Create new user playlist
    def create_playlist(name, description='', songs=[])
      @client.request('createPlaylist', {
        'playlistName' => name,
        'playlistAbout' => description,
        'songIDs' => songs.map { |s| s.kind_of?(Song) ? s.id : s.to_s }
      })
    end
    
    # --------------------------------------------------------------------------
    # User Favorites
    # --------------------------------------------------------------------------
    
    # Get user favorites
    def favorites
      return @favorites if @favorites
      resp = @client.request('getFavorites', :ofWhat => 'Songs', :userID => @id)
      @favorites = resp.map { |s| Song.new(s) }
    end
    
    # Add song to favorites
    def add_favorite(song)
      song_id = song.kind_of?(Song) ? song.id : song
      @client.request('favorite', {:what => 'Song', :ID => song_id})
    end
    
    # Remove song from favorites
    def remove_favorite(song)
      song_id = song.kind_of?(Song) ? song.id : song
      @client.request('unfavorite', {:what => 'Song', :ID => song_id})
    end
  end
end
