module Grooveshark
  class Client
    include Grooveshark::Request
    
    attr_accessor :session, :comm_token
    attr_reader :user, :comm_token_ttl, :country
  
    def initialize(session=nil)
      @session, @country = get_session_and_country
      @uuid = UUID.new.generate.upcase
      get_comm_token
    end
    
    protected

    def get_session_and_country
      response = RestClient.get('http://grooveshark.com')
      session = response.headers[:set_cookie].to_s.scan(/PHPSESSID=([a-z\d]{32});/i).flatten.first
      config_json = response.to_s.scan(/window.gsConfig = (\{.*?\});/).flatten.first
      raise GeneralError, "gsConfig not found" if not config_json
      config = JSON.parse(config_json)
      [session, config['country']]
    end
    
    # Get communication token
    def get_comm_token
      @comm_token = nil # request() uses it
      @comm_token = request('getCommunicationToken', {:secretKey => Digest::MD5.hexdigest(@session)}, true)
      @comm_token_ttl = Time.now.to_i
    end
    
    # Sign method
    def create_token(method)
      rnd = get_random_hex_chars(6)
      salt = get_method_salt(method)
      plain = [method, @comm_token, salt, rnd].join(':')
      hash = Digest::SHA1.hexdigest(plain)
      "#{rnd}#{hash}"
    end

    def get_random_hex_chars(length)
      chars = ('a'..'f').to_a | (0..9).to_a
      (0...length).map { chars[rand(chars.length)] }.join
    end
    
    public
    
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
      results = request('getResultsFromSearch', {:type => type, :query => query})['result']
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
      result = request('getStreamKeyFromSongIDEx', {
        'type' => 0,
        'prefetch' => false,
        'songID' => song_id,
        'country' => @country,
        'mobile' => false,
      })
      if result == [] then
        raise GeneralError, "No data for this song. Maybe Grooveshark banned your IP."
      end
      result
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

    private

    def get_method_salt(method)
      get_method_client(method) == 'jsqueue' ? 'closeButNoCigar' : 'breakfastBurritos'
    end
  end
end
