require 'faraday_middleware'

module Grooveshark
  WEBSITE_URL     = 'http://grooveshark.com'
  API_BASE        = 'cowbell.grooveshark.com'
  UUID            = 'A3B724BA-14F5-4932-98B8-8D375F85F266'
  CLIENT          = 'htmlshark'
  CLIENT_REV      = '20110606.04'
  COUNTRY         = {"CC2" => "0", "IPR" => "353", "CC4" => "1073741824", "CC3" => "0", "CC1" => "0", "ID" => "223"}
  SALT            = 'backToTheScienceLab'
  TOKEN_TTL       = 120 # 2 minutes
  
  # User agent overrides for different methods
  METHOD_CLIENTS = {
    'getStreamKeyFromSongIDEx' => 'jsqueue' 
  }
    
  # Salt overrides for different methods
  METHOD_SALTS = { 
    'getStreamKeyFromSongIDEx' => 'bewareOfBearsharktopus'
  }
  
  module Connection
    protected
    
    # Creates a new faraday connection
    #
    # https - Use secure connection (default: false)
    #
    # @return [Faraday::Connection]
    #
    def connection(https=false)
      base_url = https ? 'https://' : 'http://'
      base_url << API_BASE
      
      Faraday.new(base_url) do |c|
        # c.use(Faraday::Response::Logger)   # DEBUG OUTPUT
        c.use(Faraday::Request::UrlEncoded)
        c.use(Faraday::Response::ParseJson)
        c.adapter(Faraday.default_adapter)
      end
    end
      
    # Request a new session token
    #
    # @return [String]
    #
    def request_session_token
      resp = Faraday.get(WEBSITE_URL)
      resp.headers[:set_cookie].to_s.scan(/PHPSESSID=([a-z\d]{32});/i).flatten.first 
    end
  end
end
