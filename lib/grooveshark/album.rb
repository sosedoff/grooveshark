module Grooveshark
  class Album
    attr_reader :album_id, :album_name_id, :name
    attr_reader :artist_id, :year, :cover_art_filename
    attr_reader :artist_name, :is_verified
    attr_reader :songs
    
    # Initialize a new Grooveshark::Album object
    #
    # client - Grooveshark::Client
    # data   - Album data hash
    #
    def initialize(client, data=nil)
      unless client.kind_of?(Grooveshark::Client)
        raise ArgumentError, "Grooveshark::Client required!"
      end
      
      @client = client
      unless data.nil?
        @album_id             = data['album_id'].to_i
        @album_name_id        = data['album_name_id'].to_i
        @name                 = data['name']
        @artist_id            = data['artist_id'].to_i
        @year                 = data['year']
        @cover_art_filename   = data['cover_art_filename']
        @artist_name          = data['artist_name']
        @is_verified          = data['is_verified']
      end
    end
    
    # Returns a string representation of song
    #
    def to_s
      [@album_id, @name].join(' - ')
    end
    
    # Returns (and if possible stores) the album songs
    #
    # @return [Array]
    #
    def songs
      @songs ||= @client.get_songs_by_album_id(@album_id)
    end
    
  end
end