module Grooveshark
  class Client
    include Grooveshark::Connection
    include Grooveshark::Request
    
    attr_accessor :session
    attr_reader   :communication_token
    attr_reader   :communication_token_ttl
    attr_reader   :user
  
    # Initialize a new Grooveshark::Client instance
    #
    # session - Valid session ID (optional)
    # 
    def initialize(session=nil)
      @session = session || request_session_token
      request_communication_token
    end
      
    # Authenticate user
    #
    # user     - Grooveshark account username
    # password - Grooveshark account password
    #
    # @return [Grooveshark::User]
    #
    def login(user, password)
      data = request('authenticateUser', {:username => user, :password => password}, true)
      @user = User.new(self, data)
      raise InvalidAuthentication, 'Wrong username or password!' if @user.id == 0
      return @user
    end
    
    # Find user by ID
    #
    # id - Grooveshark user ID
    #
    # @return [Grooveshark::User]
    #
    def get_user_by_id(id)
      resp = request('getUserByID', {:userID => id})['user']
      resp['username'].empty? ? nil : User.new(self, resp)
    end
    
    # Find user by account username
    #
    # name - Grooveshark user username
    #
    # @return [Grooveshark::User]
    #
    def get_user_by_username(name)
      resp = request('getUserByUsername', {:username => name})['user']
      resp['username'].empty? ? nil : User.new(self, resp)
    end
    
    # Get recently active users
    #
    def recently_active_users
      request('getRecentlyActiveUsers', {})['users'].map { |u| User.new(self, u) }
    end
    
    # Returns a collection of popular songs for the time period
    #
    # type - daily, monthly
    #
    def popular_songs(type='daily')
      unless ['daily', 'monthly'].include?(type)
        raise ArgumentError, "Invalid type: #{type}."
      end
      request('popularGetSongs', {:type => type})['songs'].map { |s| Song.new(self, s) }
    end
      
    # Returns a collection of songs found for query
    #
    # query - Search query (ex.: AC/DC - Back In Black)
    #
    def search_songs(query)
      search(:songs, query).map { |record| Song.new(self, record) }
    end
    
    alias :songs :search_songs
    
    # Returns a collection of artists
    #
    # query - Search query (ex.: AC/DC)
    #
    # @return [Array]
    #
    def search_artists(query)
      search(:artists, query).map { |record| Artist.new(self, record) }
    end
    
    alias :artists :search_artists
    
    # Returns a stream authentication for song
    #
    # song - Grooveshark::Song object or ID
    #
    def get_stream_auth(song)
      song_id = song.kind_of?(Grooveshark::Song) ? song.id : song.to_s
      
      request('getStreamKeyFromSongIDEx', {
        'songID'    => song_id,
        'prefetch'  => false,
        'mobile'    => false,
        'country'   => COUNTRY
      })
    end
    
    # Returns a direct streaming url for song
    #
    # song - Grooveshark::Song object or ID
    #
    # @return [String]
    # 
    def get_song_url(song)
      auth = get_stream_auth(song)
      "http://#{auth['ip']}/stream.php?streamKey=#{auth['stream_key']}"
    end
    
    # Returns an album object
    #
    # id - album id from song
    #
    # @return Grooveshark::Album
    #
    def get_album_by_id(id)
      Album.new(self, request('getAlbumByID', { :albumID => id }))
    end
    
    # Returns an array of Song objects
    #
    # id - the album id
    #
    # @return [Array]
    #
    def get_songs_by_album_id(id)
      songs = []
      request('albumGetSongs', {:albumID => id, :isVerified => true, :offset => 0})['songs'].each { |s| songs << Song.new(self, s)}
      
      return songs
    end
    
    protected
    
    # Returns a collection of search results
    #
    # type  - Search index (artists, songs)
    # query - Search query
    #
    # @return [Array]
    #
    def search(type, query)
      type = type.to_s.capitalize
      unless ['Songs', 'Artists'].include?(type)
        raise ArgumentError, "Invalid search type: #{type}."
      end    
      request('getSearchResults', {:type => type, :query => query})[type.downcase]
    end
    
  end
end
