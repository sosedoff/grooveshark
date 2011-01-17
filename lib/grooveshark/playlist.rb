module Grooveshark
  class Playlist
    attr_reader :id, :user_id
    attr_reader :name, :about, :picture, :username
    attr_reader :songs
    
    def initialize(client, data=nil, user_id=nil)
      @client = client
      @songs = []
    
      if data
        @id       = data['playlist_id']
        @name     = data['name']
        @about    = data['about']
        @picture  = data['picture']
        @user_id  = data['user_id'] || user_id
        @username = data['user_name']
      end
    end

    # Fetch playlist songs
    def load_songs
      @songs = @client.request('playlistGetSongs', :playlistID => @id)['songs']
      @songs.map! { |s| Song.new(s) }
    end
    
    # Rename playlist
    def rename(name, description)
      begin
        @client.request('renamePlaylist', :playlistID => @id, :playlistName => name)
        @client.request('setPlaylistAbout', :playlistID => @id, :about => description)
        @name = name ; @about = description
        return true
      rescue
        return false
      end
    end
    
    # Delete existing playlist
    def delete
      @client.request('deletePlaylist', {:playlistID => @id, :name => @name})
    end
  end
end