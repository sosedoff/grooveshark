module Grooveshark
  module Request
    TOKEN_TTL = 120 # 2 minutes
    
    # Perform API request
    def request(method, params={}, secure=false)
      refresh_token if @comm_token
      
      url = "#{secure ? 'https' : 'http'}://grooveshark.com/more.php?#{method}"
      body = {
        'header' => {
          'client' => get_method_client(method),
          'clientRevision' => get_method_client_revision(method),
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
        data = RestClient.post(url, body.to_json, {
          'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/21.0.1180.77 Safari/537.1',
          'Content-Type' => 'application/json',
          'Referer' => get_method_referer(method)
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
      jsqueue_methods = [
        'getStreamKeyFromSongIDEx', 
        'addSongsToQueue', 
        'markSongDownloadedEx', 
        'markStreamKeyOver30Seconds', 
        'markSongQueueSongPlayed',
        'markSongComplete'
      ]
      jsqueue_methods.include?(method) ? 'jsqueue' : 'htmlshark'
    end

    def get_method_client_revision(method)
      get_method_client(method) == 'jsqueue' ? '20120227' : '20120227.01'
    end

    def get_method_referer(method)
      "http://grooveshark.com/JSQueue.swf?20120521.02" if get_method_client(method) == 'jsqueue'
    end
  end
end
