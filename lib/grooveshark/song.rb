module Grooveshark
  class Song
    attr_reader :data
    attr_reader :id, :artist_id, :album_id
    attr_reader :name, :artist, :album, :track
    attr_reader :duraion, :artwork, :playcount
  
    def initialize(data=nil)
      unless data.nil?
        @data       = data
        @id         = data['SongID']
        @name       = data['SongName'] || data['Name']
        @artist     = data['ArtistName']
        @artist_id  = data['ArtistID']
        @album      = data['AlbumName']
        @album_id   = data['AlbumID']
        @track      = data['TrackNum']
        @duration   = data['EstimateDuration']
        @artwork    = data['CoverArtFilename']
        @playcount  = data['SongPlays']
      end
    end
    
    def to_s
      [@id, @name, @artist].join(' - ')
    end
    
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
