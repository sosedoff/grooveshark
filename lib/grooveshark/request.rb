module Grooveshark
  module Request
    API_BASE = 'cowbell.grooveshark.com'
    UUID = 'E2AB1A59-C6B7-480E-992A-55DE1699D7F8'
    CLIENT = 'htmlshark'
    CLIENT_REV = '20101012.37'
    COUNTRY = {"CC2" => "0","IPR" => "1","CC1" => "0","ID" => "1","CC4" => "0","CC3" => "0"}
    
    # Client overrides for different methods
    METHOD_CLIENTS = {
      'getStreamKeyFromSongIDEx' => 'jsqueue' 
    }
    
    # Perform API request
    def request(method, params, secure=false)
      agent = METHOD_CLIENTS.key?(method) ? METHOD_CLIENTS[method] : CLIENT
      url = "#{secure ? 'https' : 'http'}://#{API_BASE}/more.php?#{method}"
      body = {
        'header' => {
          'session' => @session,
          'uuid' => UUID,
          'client' => agent,
          'clientRevision' => CLIENT_REV,
          'country' => COUNTRY
        },
        'method' => method,
        'parameters' => params
      }
      body['header']['token'] = create_token(method) if @comm_token
      
      begin
        data = RestClient.post(
          url, body.to_json,
          :content_type => :json,
          :accept => :json,
          :cookie => "PHPSESSID=#{@session}"
        )
      rescue Exception => ex
        raise GeneralError    # Need define error handling
      end
      
      data = JSON.parse(data)
      return data['result'] unless data['fault']
    end
  end
end