module Grooveshark
  module Request
    TOKEN_TTL = 120 # 2 minutes
    
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
      get_comm_token if Time.now.to_i - @comm_token_ttl > TOKEN_TTL
    end
  end
end
