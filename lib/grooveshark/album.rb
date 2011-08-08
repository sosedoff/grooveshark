module Grooveshark
  class Album
    attr_reader :album_id, :album_name_id, :name
    attr_reader :artist_id, :year, :cover_art_filename
    attr_reader :artist_name, :is_verified
    attr_reader :songs
    
    def initialize(data = {}, songs = [])
      
      # Assign variables
      @album_id             = data['album_id'].to_i
      @album_name_id        = data['album_name_id'].to_i
      @name                 = data['name']
      @artist_id            = data['artist_id'].to_i
      @year                 = data['year']
      @cover_art_filename   = data['cover_art_filename']
      @artist_name          = data['artist_name']
      @is_verified          = data['is_verified']
      
      # Assign songs of the album
      @songs = songs
    end
    
    def to_s
      [@album_id, @name].join(' - ')
    end
    
  end
end