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
    def login(user, password)
      data = request('authenticateUser', {:username => user, :password => password}, true)
      @user = User.new(self, data)
      raise InvalidAuthentication, 'Wrong username or password!' if @user.id == 0
      return @user
    end
    
    # Find user by ID
    def get_user_by_id(id)
      resp = request('getUserByID', {:userID => id})['user']
      resp['username'].empty? ? nil : User.new(self, resp)
    end
    
    # Find user by username
    def get_user_by_username(name)
      resp = request('getUserByUsername', {:username => name})['user']
      resp['username'].empty? ? nil : User.new(self, resp)
    end
    
    # Get recently active users
    def recent_users
      request('getRecentlyActiveUsers', {})['users'].map { |u| User.new(self, u) }
    end
    
    # Get popular songs
    # type => daily, monthly
    def popular_songs(type='daily')
      raise ArgumentError, 'Invalid type' unless ['daily', 'monthly'].include?(type)
      request('popularGetSongs', {:type => type})['songs'].map { |s| Song.new(s) }
    end
      
    # Perform search request for query
    def search(type, query)
      results = request('getSearchResults', {:type => type, :query => query})['songs']
      results.map { |song| Song.new song }
    end
    
    # Perform songs search request for query
    def search_songs(query)
      search('Songs', query)
    end
    
    # Return raw response for songs search request
    def search_songs_pure(query)
      request('getSearchResultsEx', {:type => 'Songs', :query => query})
    end
    
    # Get stream authentication by song ID
    def get_stream_auth_by_songid(song_id)
      request('getStreamKeyFromSongIDEx', {
        'songID'    => song_id,
        'prefetch'  => false,
        'mobile'    => false,
        'country'   => COUNTRY
      })
    end
  
    # Get stream authentication for song object
    def get_stream_auth(song)
      get_stream_auth_by_songid(song.id)
    end
    
    # Get song stream url by ID
    def get_song_url_by_id(id)
      resp = get_stream_auth_by_songid(id)
      "http://#{resp['ip']}/stream.php?streamKey=#{resp['stream_key']}"
    end
    
    # Get song stream
    def get_song_url(song)
      get_song_url_by_id(song.id)
    end
  end
end
