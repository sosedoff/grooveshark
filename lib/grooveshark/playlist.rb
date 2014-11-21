# Grooveshark module
module Grooveshark
  # Playlist class
  class Playlist
    attr_reader :id, :user_id
    attr_reader :name, :about, :picture, :username
    attr_reader :songs

    def initialize(client, data = nil, user_id = nil)
      @client = client
      @songs = []

      return if data.nil?
      @id       = data['playlist_id']
      @name     = data['name']
      @about    = data['about']
      @picture  = data['picture']
      @user_id  = data['user_id'] || user_id
      @username = data['user_name']
    end

    # Fetch playlist songs
    def load_songs
      @songs = []
      playlist = @client.request('getPlaylistByID', playlistID: @id)
      @songs = playlist['songs'].map! do |s|
        Song.new(s)
      end if playlist.key?('songs')
      @songs
    end

    # Rename playlist
    def rename(name, description)
      @client.request('renamePlaylist', playlistID: @id, playlistName: name)
      @client.request('setPlaylistAbout', playlistID: @id, about: description)
      @name = name
      @about = description
      true
    rescue
      false
    end

    # Delete existing playlist
    def delete
      @client.request('deletePlaylist', playlistID: @id, name: @name)
    end
  end
end
