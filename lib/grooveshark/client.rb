# Grooveshark module
module Grooveshark
  # Client class
  class Client
    attr_accessor :session, :comm_token
    attr_reader :user, :comm_token_ttl, :country

    def initialize(params = {})
      @ttl = params[:ttl] || 120 # 2 minutes
      @uuid = UUID.new.generate.upcase
      token_data
    end

    # Authenticate user
    def login(user, password)
      data = request('authenticateUser',
                     { username: user, password: password },
                     true)
      @user = User.new(self, data)
      fail InvalidAuthentication, 'Wrong username or password!' if @user.id == 0

      @user
    end

    # Find user by ID
    def get_user_by_id(id)
      resp = request('getUserByID', userID: id)['user']
      resp['username'].empty? ? nil : User.new(self, resp)
    end

    # Find user by username
    def get_user_by_username(name)
      resp = request('getUserByUsername', username: name)['user']
      resp['username'].empty? ? nil : User.new(self, resp)
    end

    # Get recently active users
    def recent_users
      request('getRecentlyActiveUsers', {})['users']
        .map do |u|
        User.new(self, u)
      end
    end

    # Get popular songs
    # type => daily, monthly
    def popular_songs(type = 'daily')
      fail ArgumentError, 'Invalid type' unless %w(daily monthly).include?(type)
      request('popularGetSongs', type: type)['songs'].map { |s| Song.new(s) }
    end

    # Get top broadcasts
    # count => specifies how many broadcasts to get
    def top_broadcasts(count = 10)
      top_broadcasts = []
      request('getTopBroadcastsCombined').each do |key, _val|
        broadcast_id = key.split(':')[1]
        top_broadcasts.push(Broadcast.new(self, broadcast_id))
        count -= 1
        break if count == 0
      end

      top_broadcasts
    end

    # Perform search request for query
    def search(type, query)
      results = []
      search = request('getResultsFromSearch', type: type, query: query)
      results = search['result'].map do |song|
        Song.new song
      end if search.key?('result')
      results
    end

    # Perform songs search request for query
    def search_songs(query)
      search('Songs', query)
    end

    # Return raw response for songs search request
    def search_songs_pure(query)
      request('getSearchResultsEx', type: 'Songs', query: query)
    end

    # Get stream authentication by song ID
    def get_stream_auth_by_songid(song_id)
      result = request('getStreamKeyFromSongIDEx',
                       'type' => 0,
                       'prefetch' => false,
                       'songID' => song_id,
                       'country' => @country,
                       'mobile' => false)
      if result == []
        fail GeneralError, 'No data for this song. ' \
             'Maybe Grooveshark banned your IP.'
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

    def token_data
      response = RestClient.get('http://grooveshark.com')

      preload_regex = /gsPreloadAjax\(\{url: '\/preload.php\?(.*)&hash=' \+ clientPage\}\)/ # rubocop:disable Metrics/LineLength
      preload_id = response.to_s.scan(preload_regex).flatten.first
      preload_url = "http://grooveshark.com/preload.php?#{preload_id}" \
                    '&getCommunicationToken=1&hash=%2F'
      preload_response = RestClient.get(preload_url)

      token_data_json = preload_response.to_s
                        .scan(/window.tokenData = (.*);/).flatten.first
      fail GeneralError, 'token data not found' unless token_data_json
      token_data = JSON.parse(token_data_json)
      @comm_token = token_data['getCommunicationToken']
      @comm_token_ttl = Time.now.to_i
      config = token_data['getGSConfig']
      @country = config['country']
      @session = config['sessionID']
    end

    # Sign method
    def create_token(method)
      rnd = get_random_hex_chars(6)
      salt = 'gooeyFlubber'
      plain = [method, @comm_token, salt, rnd].join(':')
      hash = Digest::SHA1.hexdigest(plain)
      "#{rnd}#{hash}"
    end

    def get_random_hex_chars(length)
      chars = ('a'..'f').to_a | (0..9).to_a
      (0...length).map { chars[rand(chars.length)] }.join
    end

    def body(method, params)
      body = {
        'header' => {
          'client' => 'mobileshark',
          'clientRevision' => '20120830',
          'country' => @country,
          'privacy' => 0,
          'session' => @session,
          'uuid' => @uuid
        },
        'method' => method,
        'parameters' => params
      }
      body['header']['token'] = create_token(method) if @comm_token
      body
    end

    # Perform API request
    def request(method, params = {}, secure = false)
      refresh_token if @comm_token

      url = "#{secure ? 'https' : 'http'}://grooveshark.com/more.php?#{method}"
      begin
        data = RestClient.post(url,
                               body(method, params).to_json,
                               'Content-Type' => 'application/json')
      rescue StandardError => ex
        raise GeneralError, ex.message
      end

      data = JSON.parse(data)
      data = data.normalize if data.is_a?(Hash)

      if data.key?('fault')
        fail ApiError, data['fault']
      else
        data['result']
      end
    end

    # Refresh communications token on ttl
    def refresh_token
      token_data if Time.now.to_i - @comm_token_ttl > @ttl
    end
  end
end
