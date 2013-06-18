module Grooveshark
  class Client
    attr_accessor :session, :comm_token
    attr_reader :user, :comm_token_ttl, :country
  
    def initialize(params = {})
      @ttl = params[:ttl] || 120 # 2 minutes
      @session, @country = get_session_and_country
      @uuid = UUID.new.generate.upcase
      get_comm_token
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
      salt = 'gooeyFlubber'
      plain = [method, @comm_token, salt, rnd].join(':')
      hash = Digest::SHA1.hexdigest(plain)
      "#{rnd}#{hash}"
    end

    def get_random_hex_chars(length)
      chars = ('a'..'f').to_a | (0..9).to_a
      (0...length).map { chars[rand(chars.length)] }.join
    end
    
    private

    # Perform API request
    def request(method, params={}, secure=false)
      refresh_token if @comm_token
      
      url = "#{secure ? 'https' : 'http'}://grooveshark.com/more.php?#{method}"
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

      begin
        data = RestClient.post(url, body.to_json, {'Content-Type' => 'application/json'})
      rescue Exception => ex
        raise GeneralError, ex.message
      end

      data = JSON.parse(data)
      data = data.normalize if data.kind_of?(Hash)

      if data.key?('fault')
        raise ApiError.new(data['fault'])
      else
        data['result']
      end
    end
    
    # Refresh communications token on ttl
    def refresh_token
      get_comm_token if Time.now.to_i - @comm_token_ttl > @ttl
    end

    public
    # "getItemByPageName" - try a username
    def getItemByPageName(name)
      request('getItemByPageName', {'name' => name})
    end

    # "getUserProfileFeed" - user id, and try 0 and 0 for first page
    def getUserProfileFeed(userID, lastDocumentID, lastEventID)
      request('getUserProfileFeed', {'userID' => userID, 'lastDocumentID' => lastDocumentID, 'lastEventID' => lastEventID})
    end

    # "getProfileFeed" - try 0 and 0 for first page (requires logged in)
    def getProfileFeed(lastDocumentID, lastEventID)
      request('getProfileFeed', {'lastDocumentID' => lastDocumentID, 'lastEventID' => lastEventID})
    end

    # Gets all of a user's profile feed, as an array of the pages returned individually.
    # Useful for obtaining a log of what you've ever listened to, as far back as can be had,
    # since I think Grooveshark's been removing songs and all traces of them except for the logs.
    # I wanted to have a list of what songs used to be on my favorites list, before Grooveshark
    # erased them.  Warning: it will probably be a large list.
    def getAllUserFeed(userID)
      i = 0
      feed = Array.new
      feed[i] = getUserProfileFeed(userID, 0, 0)
      count = feed[i]["count"]
      i += 1
      while count > 0
        feed[i] = getUserProfileFeed(userID, feed[i-1]["last_document_id"], feed[i-1]["last_event_id"])
        count = feed[i]["count"]
        i += 1
      end
      feed
    end

# streamServerID is actually "ip" as returned from getStreamKeyFromSongIDEx
def markSongDownloadedEx(streamKey, streamServerID, songID)
  request('markSongDownloadedEx', {'streamKey' => streamKey, 'streamServerID' => streamServerID, 'songID' => songID})
end

# streamServerID is actually "ip" as returned from getStreamKeyFromSongIDEx
# no idea where songQueueID comes from
# songQueueSongID is the song's place in the queue
def markQueueSongPlayed(streamKey, streamServerID, songID, songQueueID, songQueueSongID)
  request('markQueueSongPlayed', {'streamKey' => streamKey, 'streamServerID' => streamServerID, 'songID' => songID, 'songQueueID' => songQueueID, 'songQueueSongID' => songQueueSongID})
end

# streamServerID is actually "ip" as returned from getStreamKeyFromSongIDEx
# no idea where songQueueID comes from
# songQueueSongID is the song's place in the queue
def markStreamKeyOver30Seconds(streamKey, streamServerID, songID, songQueueID, songQueueSongID)
  request('markStreamKeyOver30Seconds', {'streamKey' => streamKey, 'streamServerID' => streamServerID, 'songID' => songID, 'songQueueID' => songQueueID, 'songQueueSongID' => songQueueSongID})
end

# markSongComplete takes crazy input.  I can't tell you exactly how to get what it's asking for, yet.
# Here's my notes, though.
#markSongComplete
#	streamKey
#	song (bunch of data about the song)
#	streamServerID (actually "ip" as returned from getStreamKeyFromSongIDEx)
#	songID
#	context
#		type (eg., "user")
#		data
#			userID
#			location
#			picture
#			client
#			userName
#			isPremium
#	user
#		userID
#		picture
#		username
#		isPremium
def markSongComplete(streamKey, song, streamServerID, songID, context, user)
  request('markSongComplete', {'streamKey' => streamKey, 'song' => song, 'streamServerID' => streamServerID, 'songID' => songID, 'context' => context, 'user' => user})
end

def getAlbumByID(albumID)
  request('getAlbumByID', {'albumID' => albumID})
end

def albumGetAllSongs(albumID)
  request('albumGetAllSongs', {'albumID' => albumID})
end
    
def userGetPlaylists(userID)
  request('userGetPlaylists', {'userID' => userID})
end

# ofWhat is one of ["Albums", "Artists", "Playlists", "Songs", "Users"]
def getFavorites(userID, ofWhat)
  request('getFavorites', {'userID' => userID, 'ofWhat' => ofWhat})
end

# requires logged in
def getUserSidebar
  request('getUserSidebar', {})
end

# no idea what this even does
def userGetLibraryTSModified(userID)
  request('userGetLibraryTSModified', {'userID' => userID})
end

# The examples of type that I've seen have all been "user"
def getPageInfoByIDType(id, type)
  request('getPageInfoByIDType', {'id' => id, 'type' => type})
end

# songIDs is an array of song ids
def getQueueSongListFromSongIDs(songIDs)
  request('getQueueSongListFromSongIDs', {'songIDs' => songIDs})
end

# requires logged in
def getUserNotifications
  request('getUserNotifications', {})
end

# dunno where songQueueID comes from.
# songIDsArtistIDs is an map of {'source', 'artistID', 'songID', 'songQueueSongID'};
# 'source' was 'user' wherever I saw it, and 'songQueueSongID' was the song's place in the queue.
def addSongsToQueue(songQueueID, songIDsArtistIDs)
  request('addSongsToQueue', {'songQueueID' => songQueueID, 'songIDsArtistIDs' => songIDsArtistIDs})
end

# I dunno what this does; I only ever saw it used once.
def getTokenForSong(songID, country)
  request('getTokenForSong', {'songID' => songID, 'country' => country})
end

# type always seems to be 'artist'.
def getAutocomplete(query, type)
  request('getAutocomplete', {'query' => query, 'type' => type})
end

# Raw search.  Type can be an array of any of ["Songs", "Albums", "Artists", "Playlists", "Users", "EventsAndDarFM"]
# and maybe others.  I don't know what 'guts' and 'ppOverride' do, but they were usually 0 and "" respectively.
def getResultsFromSearch(query, type, guts, ppOverride)
  request('getResultsFromSearch', {'query' => query, 'type' => type, 'guts' => guts, 'ppOverride' => ppOverride})
end

# It's like the singular version, except with an array of songIDs.
    def getStreamKeysFromSongIDs(songIDs)
      result = request('getStreamKeyFromSongIDEx', {
        'type' => 0,
        'prefetch' => false,
        'songIDs' => songIDs,
        'country' => @country,
        'mobile' => false,
      })
      if result == [] then
        raise GeneralError, "No data for this song. Maybe Grooveshark banned your IP."
      end
      result
    end

def playlistGetSongs(playlistID)
  request('playlistGetSongs', {'playlistID' => playlistID})
end

def playlistGetFans(playlistID)
  request('playlistGetFans', {'playlistID' => playlistID})
end

def userGetSongsInLibrary(userID, page)
  request('userGetSongsInLibrary', {'userID' => userID, 'page' => page})
end

  end
end
