module Grooveshark
  module Request
    COUNTRY = {
      'CC1' => 72057594037927940, 
      'CC2' => 0, 
      'CC3' => 0, 
      'CC4' => 0, 
      'ID' => 57,
      'IPR' => 0 
    }
    TOKEN_TTL = 120 # 2 minutes
    
    # Perform API request
    def request(method, params={}, secure=false)
      refresh_token if @comm_token
      
      url = "#{secure ? 'https' : 'http'}://grooveshark.com/more.php?#{method}"
      body = {
        'header' => {
          'client' => get_method_client(method),
          'clientRevision' => get_method_client_revision(method),
          'country' => COUNTRY,
          'privacy' => 0,
          'session' => @session,
          'uuid' => 'A3B724BA-14F5-4932-98B8-8D375F85F266',
        },
        'method' => method,
        'parameters' => params
      }
      body['header']['token'] = create_token(method) if @comm_token

      begin
        data = RestClient.post(url, body.to_json, {
          'User-Agent' => "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5",
          'Content-Type' => 'application/json',
          'Accept-Encoding' => 'gzip'
        })
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
      get_comm_token if Time.now.to_i - @comm_token_ttl > TOKEN_TTL
    end

    private

    def get_method_client(method)
      case method
      when 'getStreamKeysFromSongIDs'
        'jsqueue'
      else
        'htmlshark'
      end
    end

    def get_method_client_revision(method)
      case get_method_client(method)
      when 'jsqueue'
        '20120312.08'
      else
        20120312
      end
    end
  end
end
