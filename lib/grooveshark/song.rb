module Grooveshark
  class Song
    attr_reader :data
    attr_reader :id, :artist_id, :album_id
    attr_reader :name, :artist, :album, :track, :year
    attr_reader :duration, :artwork, :playcount
  
    def initialize(data=nil)
      unless data.nil?
        @data       = data
        @id         = data['song_id']
        @name       = data['song_name'] || data['name']
        @artist     = data['artist_name']
        @artist_id  = data['artist_id']
        @album      = data['album_name']
        @album_id   = data['album_id']
        @track      = data['track_num']
        @duration   = data['estimate_duration']
        @artwork    = data['cover_art_filename']
        @playcount  = data['song_plays']
        @year       = data['year']
      end
    end
    
    # Presentable format
    def to_s
      [@id, @name, @artist].join(' - ')
    end
    
    # Hash export for API usage
    def to_hash
      {
        'songID'      => @id,
        'songName'    => @name,
        'artistName'  => @artist,
        'artistID'    => @artist_id,
        'albumName'   => @album,
        'albumID'     => @album_id,
        'track'       => @track
      }
    end
  end
end
